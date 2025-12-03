import pandas as pd
import mysql.connector

#host = '159.223.76.99'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

host = '127.0.0.1'
user = 'real-research'
password = 'shA0Y69X06jkiAgaX&ng'

#save_file = rf"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\office\output.csv"
save_file = r"/home/gitprod/ta_python/gen_office_user/output.csv"

sql = False
try:
    connection = mysql.connector.connect(
        host = host,
        user = user,
        password = password,
        database = 'realist_office'
    )
    if connection.is_connected():
        print('Connected to MySQL server')
        cursor = connection.cursor(dictionary=True)
        sql = True
    
except Exception as e:
    print(f'Error: {e}')

query = """
        -- =========================
        -- Main evaluation query (no SET variables)
        -- =========================

        WITH
        params AS (
        SELECT
        -- =========================
        -- User-adjustable parameters
        -- =========================

        -- SIZE: exact OR range (set one style)
        -- If you want exact size, set size_want_min = size_want_max = exact size.
        200.0 AS size_want_min,     -- e.g. 200
        250.0 AS size_want_max,     -- e.g. 250

        -- Asymmetric tolerances for size (percent of boundary)
        0.10  AS size_tol_low_pct,  -- stricter if smaller than min
        0.20  AS size_tol_high_pct, -- looser if larger than max

        -- ===== Existing criteria weights =====
        -- (Updated to range 1..10)
        4  AS w_floor,          -- ชั้นของห้อง
        4  AS w_dir,            -- ทิศของห้อง
        4  AS w_ceiling,        -- ความสูงเพดาน
        2  AS w_columns,        -- ต้นเสาภายในห้อง
        6  AS w_bathroom,       -- ห้องน้ำภายในห้อง
        8  AS w_pantry,         -- ห้องครัว/แพนทรีในห้อง

        -- Existing main weight
        10 AS w_size,           -- ขนาดพื้นที่ (สำคัญมาก)

        -- ===== New criteria weights =====
        2  AS w_deposit,        -- เงินมัดจำ
        2  AS w_advance,        -- ค่าเช่าล่วงหน้า
        4  AS w_common_pantry,  -- Pantry ส่วนกลาง
        6  AS w_security,       -- ระบบความปลอดภัย
        4  AS w_passenger_lift, -- จำนวนลิฟต์โดยสาร
        2  AS w_service_lift,   -- จำนวนลิฟต์ขนของ
        8  AS w_building_age,   -- ปีสร้างเสร็จ/ปรับปรุง

        -- ===== New weight: distance to train station =====
        10 AS w_train_station,  -- ระยะห่างจากสถานีรถไฟฟ้า (ยิ่งใกล้ยิ่งดี)

        -- ===== New weights: in-building facilities (office_project) =====
        2  AS w_fac_bank,          -- ธนาคาร
        2  AS w_fac_cafe,          -- คาเฟ่
        4  AS w_fac_restaurant,    -- ร้านอาหาร
        4  AS w_fac_foodcourt,     -- Food Court
        4  AS w_fac_market,        -- ตลาดขายของ
        4  AS w_fac_conv_store,    -- ร้านสะดวกซื้อ
        2  AS w_fac_pharma_clinic, -- คลีนิค / ร้านขายยา
        4  AS w_fac_ev,            -- EV Charger

        -- ===== Facility importance levels (user preference) =====
        -- 0 = ไม่สำคัญ   -> 0.5 ทุกกรณี (มี / ไม่มี / NULL)
        -- 1 = สำคัญ      -> มี = 0.75, NULL = 0.5, ไม่มี = 0.25
        -- 2 = สำคัญมาก   -> มี = 1.0,  NULL = 0.5, ไม่มี = 0
        1 AS fac_bank_pref,
        1 AS fac_cafe_pref,
        1 AS fac_restaurant_pref,
        1 AS fac_foodcourt_pref,
        1 AS fac_market_pref,
        1 AS fac_conv_store_pref,
        1 AS fac_pharma_clinic_pref,
        1 AS fac_ev_pref,

        -- Direction scoring (simple penalty model)
        -- ถ้าหันไปทาง W จะติดลบเยอะ, E ติดลบน้อย, N/S ไม่เป็นไร
        -- Values are scores in 0..1: higher = better
        1.0 AS dir_n_score,   -- North: no penalty
        1.0 AS dir_s_score,   -- South: no penalty
        0.5 AS dir_e_score,   -- East: mild penalty
        0.0 AS dir_w_score,   -- West: strong penalty

        -- Ceiling preference (meters). Score decays smoothly below this.
        2.70 AS min_ceiling_clear,

        -- Bathroom preference (ห้องน้ำในห้อง)
        -- 0 = ต้องไม่มี
        -- 1 = เฉยๆ ไม่สำคัญ
        -- 2 = มีก็ดี
        2 AS bath_pref,

        -- Pantry preference (ห้องครัว/แพนทรี)
        -- 0 = เฉยๆ ไม่สำคัญ
        -- 1 = มีก็ดี
        -- 2 = จำเป็นต้องมี
        1 AS pantry_pref,

        -- Deposit preference (months)
        --   if Rent_Deposit > 3 months       -> score = 0.25
        --   if Rent_Deposit = 3 or NULL      -> score = 0.50
        --   if Rent_Deposit < 3              -> score = 1.00
        3.0  AS rent_deposit_std,
        0.25 AS rent_deposit_score_high,
        0.50 AS rent_deposit_score_std,
        1.00 AS rent_deposit_score_low,

        -- Advance preference (months)
        --   if Rent_Advance < 1 month        -> score = 1.00
        --   if Rent_Advance = 1 or NULL      -> score = 0.50
        --   if Rent_Advance > 1              -> score = 0.25
        1.0  AS rent_advance_std,
        1.00 AS rent_advance_score_low,
        0.50 AS rent_advance_score_std,
        0.25 AS rent_advance_score_high,

        -- Binary preferences
        1.0 AS prefer_no_column,

        -- General behavior
        0.50    AS default_score,
        '1'     AS only_status,

        -- Train distance decay parameter
        -- score = 1 when d <= 0.2
        -- ≈0.5 at ~0.5 km
        2.31 AS train_decay_k
        ),

        -- =========================
        -- Nearest train station per project
        -- =========================
        station_dist AS (
        SELECT
        OAS.Project_ID,
        MIN(OAS.Distance) AS Distance_from_nearest_station   -- km
        FROM source_office_around_station OAS
        GROUP BY OAS.Project_ID
        ),

        base AS (
        SELECT
        u.*,
        ob.Building_Name,               -- << building name added
        -- building-level info
        ob.Passenger_Lift AS Building_Passenger_Lift,
        ob.Service_Lift   AS Building_Service_Lift,
        ob.Built_Complete,
        ob.Last_Renovate,
        -- project-level info
        op.F_Common_Pantry,
        op.Security_Type,
        -- new project-level facilities
        op.F_Services_Bank,
        op.F_Food_Cafe,
        op.F_Food_Restaurant,
        op.F_Food_Foodcourt,
        op.F_Food_Market,
        op.F_Retail_Conv_Store,
        op.F_Services_Pharma_Clinic,
        op.F_Others_EV,
        -- distance from nearest train station (by project)
        sd.Distance_from_nearest_station,
        -- derived
        NULLIF(REGEXP_SUBSTR(u.Floor, '[0-9]+'), '') AS floor_num_str
        FROM office_unit u
        JOIN office_building ob ON u.Building_ID = ob.Building_ID
        LEFT JOIN office_project op ON ob.Project_ID = op.Project_ID
        LEFT JOIN station_dist sd ON op.Project_ID = sd.Project_ID
        CROSS JOIN params p
        WHERE
        (p.only_status IS NULL OR u.Unit_Status = p.only_status)
        -- ห้องน้ำ: ถ้าเลือก "ต้องไม่มี" (0) ให้คัดห้องที่มีห้องน้ำออกไปเลย
        AND (p.bath_pref   <> 0 OR u.Bathroom_InUnit <> 1)
        -- ห้องครัว: ถ้าเลือก "จำเป็นต้องมี" (2) ให้คัดห้องที่ไม่มีห้องครัวออกไปเลย
        AND (p.pantry_pref <> 2 OR u.Pantry_InUnit = 1)
        ),

        floor_stats AS (
        SELECT
        b.*,
        CAST(floor_num_str AS UNSIGNED) AS floor_num,
        MIN(CAST(floor_num_str AS UNSIGNED)) OVER () AS floor_min_overall,
        MAX(CAST(floor_num_str AS UNSIGNED)) OVER () AS floor_max_overall,

        -- Security as numeric index (enum 1..N)
        CAST(b.Security_Type AS UNSIGNED) AS security_idx,
        MAX(CAST(b.Security_Type AS UNSIGNED)) OVER () AS security_max_overall,

        -- Effective building date = newer of Built_Complete / Last_Renovate
        CASE
            WHEN b.Built_Complete IS NULL AND b.Last_Renovate IS NULL THEN NULL
            WHEN b.Built_Complete IS NULL THEN TO_DAYS(b.Last_Renovate)
            WHEN b.Last_Renovate IS NULL THEN TO_DAYS(b.Built_Complete)
            WHEN b.Last_Renovate > b.Built_Complete THEN TO_DAYS(b.Last_Renovate)
            ELSE TO_DAYS(b.Built_Complete)
        END AS build_date_days,

        MIN(
            CASE
                WHEN b.Built_Complete IS NULL AND b.Last_Renovate IS NULL THEN NULL
                WHEN b.Built_Complete IS NULL THEN TO_DAYS(b.Last_Renovate)
                WHEN b.Last_Renovate IS NULL THEN TO_DAYS(b.Built_Complete)
                WHEN b.Last_Renovate > b.Built_Complete THEN TO_DAYS(b.Last_Renovate)
                ELSE TO_DAYS(b.Built_Complete)
            END
        ) OVER () AS build_date_min_overall,

        MAX(
            CASE
                WHEN b.Built_Complete IS NULL AND b.Last_Renovate IS NULL THEN NULL
                WHEN b.Built_Complete IS NULL THEN TO_DAYS(b.Last_Renovate)
                WHEN b.Last_Renovate IS NULL THEN TO_DAYS(b.Built_Complete)
                WHEN b.Last_Renovate > b.Built_Complete THEN TO_DAYS(b.Last_Renovate)
                ELSE TO_DAYS(b.Built_Complete)
            END
        ) OVER () AS build_date_max_overall,

        -- Lift stats for normalization
        MAX(b.Building_Passenger_Lift) OVER () AS passenger_lift_max_overall,
        MAX(b.Building_Service_Lift)   OVER () AS service_lift_max_overall

        FROM base b
        ),

        scored AS (
        SELECT
        f.*,
        p.*,

        -- =========================
        -- SIZE score (smooth tolerance)
        -- =========================
        CASE
            WHEN f.Size IS NULL THEN p.default_score
            WHEN f.Size BETWEEN p.size_want_min AND p.size_want_max THEN 1.0
            WHEN f.Size < p.size_want_min THEN
                1.0 / (1.0 + ((p.size_want_min - f.Size) / NULLIF(p.size_want_min * p.size_tol_low_pct, 0)))
            ELSE
                1.0 / (1.0 + ((f.Size - p.size_want_max) / NULLIF(p.size_want_max * p.size_tol_high_pct, 0)))
        END AS size_score,

        -- =========================
        -- Floor score (higher = better)
        -- =========================
        CASE
            WHEN f.floor_num IS NULL
                OR f.floor_min_overall IS NULL
                OR f.floor_max_overall IS NULL
                OR f.floor_min_overall = f.floor_max_overall
            THEN p.default_score
            ELSE (f.floor_num - f.floor_min_overall) / NULLIF(floor_max_overall - floor_min_overall, 0)
        END AS floor_score,

        -- =========================
        -- Direction score (simple penalty model)
        -- ถ้าหันไปทาง W = ติดลบเยอะ, E = ติดลบน้อย, อื่นๆ = ไม่ติดลบ
        -- If multiple directions are 1, take the worst (minimum score).
        -- If all direction fields are NULL, fall back to default_score.
        -- =========================
        CASE
            WHEN f.View_N IS NULL
                AND f.View_E IS NULL
                AND f.View_S IS NULL
                AND f.View_W IS NULL
            THEN p.default_score
            ELSE LEAST(
                IF(f.View_N = 1, p.dir_n_score, 1.0),
                IF(f.View_S = 1, p.dir_s_score, 1.0),
                IF(f.View_E = 1, p.dir_e_score, 1.0),
                IF(f.View_W = 1, p.dir_w_score, 1.0)
            )
        END AS direction_score,

        -- =========================
        -- Ceiling height score
        -- =========================
        CASE
            WHEN COALESCE(f.Ceiling_Dropped, f.Ceiling_Full_Structure) IS NULL THEN p.default_score
            WHEN COALESCE(f.Ceiling_Dropped, f.Ceiling_Full_Structure) >= p.min_ceiling_clear THEN 1.0
            ELSE 1.0 / (1.0 + (p.min_ceiling_clear - COALESCE(f.Ceiling_Dropped, f.Ceiling_Full_Structure)))
        END AS ceiling_score,

        -- =========================
        -- Column score (prefer none)
        -- =========================
        CASE
            WHEN p.prefer_no_column IS NULL THEN p.default_score
            WHEN p.prefer_no_column = 1 THEN
                CASE
                    WHEN f.Column_InUnit IS NULL THEN p.default_score
                    WHEN f.Column_InUnit = 0 THEN 1.0
                    ELSE 0.25
                END
            ELSE p.default_score
        END AS columns_score,

        -- =========================
        -- Bathroom score (ห้องน้ำในห้อง)
        -- Bath_Pref:
        -- 0 = ต้องไม่มี
        -- 1 = เฉยๆ ไม่สำคัญ
        -- 2 = มีก็ดี
        -- =========================
        CASE
            WHEN p.bath_pref = 1 THEN
                p.default_score
            WHEN p.bath_pref = 0 THEN
                CASE
                    WHEN f.Bathroom_InUnit IS NULL THEN p.default_score
                    WHEN f.Bathroom_InUnit = 1 THEN 0.0
                    ELSE 1.0
                END
            WHEN p.bath_pref = 2 THEN
                CASE
                    WHEN f.Bathroom_InUnit IS NULL THEN p.default_score
                    WHEN f.Bathroom_InUnit = 1 THEN 1.0
                    ELSE 0.2
                END
            ELSE p.default_score
        END AS bathroom_score,

        -- =========================
        -- Pantry / kitchen score (ห้องครัว/แพนทรี)
        -- Pantry_Pref:
        -- 0 = เฉยๆ ไม่สำคัญ
        -- 1 = มีก็ดี
        -- 2 = จำเป็นต้องมี
        -- =========================
        CASE
            WHEN p.pantry_pref = 0 THEN
                p.default_score
            WHEN p.pantry_pref = 1 THEN
                CASE
                    WHEN f.Pantry_InUnit IS NULL THEN p.default_score
                    WHEN f.Pantry_InUnit = 1 THEN 1.0
                    ELSE 0.2
                END
            WHEN p.pantry_pref = 2 THEN
                CASE
                    WHEN f.Pantry_InUnit = 1 THEN 1.0
                    ELSE 0.0
                END
            ELSE p.default_score
        END AS pantry_score,

        -- =========================
        -- Deposit score (เงินมัดจำ: ส่วนใหญ่ 3 เดือน)
        -- =========================
        CASE
            WHEN f.Rent_Deposit IS NULL THEN p.rent_deposit_score_std
            WHEN f.Rent_Deposit <  p.rent_deposit_std THEN p.rent_deposit_score_low
            WHEN f.Rent_Deposit =  p.rent_deposit_std THEN p.rent_deposit_score_std
            WHEN f.Rent_Deposit >  p.rent_deposit_std THEN p.rent_deposit_score_high
            ELSE p.default_score
        END AS deposit_score,

        -- =========================
        -- Advance score (ค่าเช่าล่วงหน้า: ส่วนใหญ่ 1 เดือน)
        -- =========================
        CASE
            WHEN f.Rent_Advance IS NULL THEN p.rent_advance_score_std
            WHEN f.Rent_Advance <  p.rent_advance_std THEN p.rent_advance_score_low
            WHEN f.Rent_Advance =  p.rent_advance_std THEN p.rent_advance_score_std
            WHEN f.Rent_Advance >  p.rent_advance_std THEN p.rent_advance_score_high
            ELSE p.default_score
        END AS advance_score,

        -- =========================
        -- Common pantry score (Pantry ส่วนกลาง)
        -- =========================
        CASE
            WHEN f.F_Common_Pantry IS NULL THEN p.default_score
            WHEN f.F_Common_Pantry = 1 THEN 1.0
            ELSE p.default_score
        END AS common_pantry_score,

        -- =========================
        -- Security system score (ระบบความปลอดภัย)
        -- office_project.Security_Type เป็น ENUM
        -- =========================
        CASE
            WHEN f.security_idx IS NULL
                OR f.security_max_overall IS NULL
                OR f.security_max_overall = 0
            THEN p.default_score
            ELSE f.security_idx / f.security_max_overall
        END AS security_score,

        -- =========================
        -- Passenger lift score (จำนวนลิฟต์โดยสาร)
        -- =========================
        CASE
            WHEN f.Building_Passenger_Lift IS NULL
                OR f.passenger_lift_max_overall IS NULL
                OR f.passenger_lift_max_overall = 0
            THEN p.default_score
            ELSE f.Building_Passenger_Lift / f.passenger_lift_max_overall
        END AS passenger_lift_score,

        -- =========================
        -- Service lift score (จำนวนลิฟต์ขนของ)
        -- =========================
        CASE
            WHEN f.Building_Service_Lift IS NULL
                OR f.service_lift_max_overall IS NULL
                OR f.service_lift_max_overall = 0
            THEN p.default_score
            ELSE f.Building_Service_Lift / f.service_lift_max_overall
        END AS service_lift_score,

        -- =========================
        -- Building age score (ปีที่สร้างเสร็จ/ปรับปรุง)
        -- =========================
        CASE
            WHEN f.build_date_days IS NULL
                OR f.build_date_min_overall IS NULL
                OR f.build_date_max_overall IS NULL
                OR f.build_date_max_overall = f.build_date_min_overall
            THEN p.default_score
            ELSE (f.build_date_days - f.build_date_min_overall)
                    / NULLIF(f.build_date_max_overall - f.build_date_min_overall, 0)
        END AS building_age_score,

        -- =========================
        -- Train station distance score (ระยะจากสถานีรถไฟฟ้าที่ใกล้ที่สุด)
        -- =========================
        CASE
            WHEN f.Distance_from_nearest_station IS NULL THEN 0.0
            WHEN f.Distance_from_nearest_station <= 0.2 THEN 1.0
            ELSE EXP( - p.train_decay_k * (f.Distance_from_nearest_station - 0.2) )
        END AS train_station_score,

        -- =========================
        -- Facilities in building (office_project)
        -- =========================

        -- ธนาคาร F_Services_Bank
        CASE
            WHEN p.fac_bank_pref = 0 THEN
                0.5
            WHEN p.fac_bank_pref = 1 THEN
                CASE
                    WHEN f.F_Services_Bank IS NULL THEN 0.5
                    WHEN f.F_Services_Bank = 1 THEN 0.75
                    ELSE 0.25
                END
            WHEN p.fac_bank_pref = 2 THEN
                CASE
                    WHEN f.F_Services_Bank IS NULL THEN 0.5
                    WHEN f.F_Services_Bank = 1 THEN 1.0
                    ELSE 0.0
                END
            ELSE 0.5
        END AS bank_score,

        -- คาเฟ่ F_Food_Cafe
        CASE
            WHEN p.fac_cafe_pref = 0 THEN
                0.5
            WHEN p.fac_cafe_pref = 1 THEN
                CASE
                    WHEN f.F_Food_Cafe IS NULL THEN 0.5
                    WHEN f.F_Food_Cafe = 1 THEN 0.75
                    ELSE 0.25
                END
            WHEN p.fac_cafe_pref = 2 THEN
                CASE
                    WHEN f.F_Food_Cafe IS NULL THEN 0.5
                    WHEN f.F_Food_Cafe = 1 THEN 1.0
                    ELSE 0.0
                END
            ELSE 0.5
        END AS cafe_score,

        -- ร้านอาหาร F_Food_Restaurant
        CASE
            WHEN p.fac_restaurant_pref = 0 THEN
                0.5
            WHEN p.fac_restaurant_pref = 1 THEN
                CASE
                    WHEN f.F_Food_Restaurant IS NULL THEN 0.5
                    WHEN f.F_Food_Restaurant = 1 THEN 0.75
                    ELSE 0.25
                END
            WHEN p.fac_restaurant_pref = 2 THEN
                CASE
                    WHEN f.F_Food_Restaurant IS NULL THEN 0.5
                    WHEN f.F_Food_Restaurant = 1 THEN 1.0
                    ELSE 0.0
                END
            ELSE 0.5
        END AS restaurant_score,

        -- Food Court F_Food_Foodcourt
        CASE
            WHEN p.fac_foodcourt_pref = 0 THEN
                0.5
            WHEN p.fac_foodcourt_pref = 1 THEN
                CASE
                    WHEN f.F_Food_Foodcourt IS NULL THEN 0.5
                    WHEN f.F_Food_Foodcourt = 1 THEN 0.75
                    ELSE 0.25
                END
            WHEN p.fac_foodcourt_pref = 2 THEN
                CASE
                    WHEN f.F_Food_Foodcourt IS NULL THEN 0.5
                    WHEN f.F_Food_Foodcourt = 1 THEN 1.0
                    ELSE 0.0
                END
            ELSE 0.5
        END AS foodcourt_score,

        -- ตลาดขายของ F_Food_Market
        CASE
            WHEN p.fac_market_pref = 0 THEN
                0.5
            WHEN p.fac_market_pref = 1 THEN
                CASE
                    WHEN f.F_Food_Market IS NULL THEN 0.5
                    WHEN f.F_Food_Market = 1 THEN 0.75
                    ELSE 0.25
                END
            WHEN p.fac_market_pref = 2 THEN
                CASE
                    WHEN f.F_Food_Market IS NULL THEN 0.5
                    WHEN f.F_Food_Market = 1 THEN 1.0
                    ELSE 0.0
                END
            ELSE 0.5
        END AS market_score,

        -- ร้านสะดวกซื้อ F_Retail_Conv_Store
        CASE
            WHEN p.fac_conv_store_pref = 0 THEN
                0.5
            WHEN p.fac_conv_store_pref = 1 THEN
                CASE
                    WHEN f.F_Retail_Conv_Store IS NULL THEN 0.5
                    WHEN f.F_Retail_Conv_Store = 1 THEN 0.75
                    ELSE 0.25
                END
            WHEN p.fac_conv_store_pref = 2 THEN
                CASE
                    WHEN f.F_Retail_Conv_Store IS NULL THEN 0.5
                    WHEN f.F_Retail_Conv_Store = 1 THEN 1.0
                    ELSE 0.0
                END
            ELSE 0.5
        END AS conv_store_score,

        -- คลีนิค / ร้านขายยา F_Services_Pharma_Clinic
        CASE
            WHEN p.fac_pharma_clinic_pref = 0 THEN
                0.5
            WHEN p.fac_pharma_clinic_pref = 1 THEN
                CASE
                    WHEN f.F_Services_Pharma_Clinic IS NULL THEN 0.5
                    WHEN f.F_Services_Pharma_Clinic = 1 THEN 0.75
                    ELSE 0.25
                END
            WHEN p.fac_pharma_clinic_pref = 2 THEN
                CASE
                    WHEN f.F_Services_Pharma_Clinic IS NULL THEN 0.5
                    WHEN f.F_Services_Pharma_Clinic = 1 THEN 1.0
                    ELSE 0.0
                END
            ELSE 0.5
        END AS pharma_clinic_score,

        -- EV Charger F_Others_EV
        CASE
            WHEN p.fac_ev_pref = 0 THEN
                0.5
            WHEN p.fac_ev_pref = 1 THEN
                CASE
                    WHEN f.F_Others_EV IS NULL THEN 0.5
                    WHEN f.F_Others_EV = 1 THEN 0.75
                    ELSE 0.25
                END
            WHEN p.fac_ev_pref = 2 THEN
                CASE
                    WHEN f.F_Others_EV IS NULL THEN 0.5
                    WHEN f.F_Others_EV = 1 THEN 1.0
                    ELSE 0.0
                END
            ELSE 0.5
        END AS ev_score

        FROM floor_stats f
        CROSS JOIN params p
        )

        -- =========================
        -- Output with raw data shown before each score
        -- =========================
        SELECT
        Unit_ID,
        Building_ID,
        Building_Name,   -- added here, right after Building_ID
        Unit_NO,
        Rent_Price,

        -- === Size raw + score ===
        Size,
        ROUND(size_score,3) AS Size_Score,
        ROUND(w_size * size_score, 3) AS Size_Score_Weighted,

        -- === Floor raw + score ===
        Floor,
        ROUND(floor_score,3) AS Floor_Score,
        (w_floor * floor_score) AS Floor_Score_Weighted,

        -- === Direction raw + score ===
        View_N, View_E, View_S, View_W,
        ROUND(direction_score,3) AS Direction_Score,
        (w_dir * direction_score) AS Direction_Score_Weighted,

        -- === Ceiling raw + score ===
        Ceiling_Dropped, Ceiling_Full_Structure,
        ROUND(ceiling_score,3) AS Ceiling_Score,
        (w_ceiling * ceiling_score) AS Ceiling_Score_Weighted,

        -- === Column raw + score ===
        Column_InUnit,
        ROUND(columns_score,3) AS Columns_Score,
        (w_columns * columns_score) AS Columns_Score_Weighted,

        -- === Bathroom raw + score ===
        Bathroom_InUnit,
        ROUND(bathroom_score,3) AS Bathroom_Score,
        (w_bathroom * bathroom_score) AS Bathroom_Score_Weighted,

        -- === Pantry raw + score ===
        Pantry_InUnit,
        ROUND(pantry_score,3) AS Pantry_Score,
        (w_pantry * pantry_score) AS Pantry_Score_Weighted,

        -- === Deposit raw + score ===
        Rent_Deposit,
        ROUND(deposit_score,3) AS Rent_Deposit_Score,
        (w_deposit * deposit_score) AS Rent_Deposit_Score_Weighted,

        -- === Advance rent raw + score ===
        Rent_Advance,
        ROUND(advance_score,3) AS Rent_Advance_Score,
        (w_advance * advance_score) AS Rent_Advance_Score_Weighted,

        -- === Common pantry raw + score ===
        F_Common_Pantry,
        ROUND(common_pantry_score,3) AS Common_Pantry_Score,
        (w_common_pantry * common_pantry_score) AS Common_Pantry_Score_Weighted,

        -- === Security system raw + score ===
        Security_Type,
        ROUND(security_score,3) AS Security_Score,
        (w_security * security_score) AS Security_Score_Weighted,

        -- === Lifts raw + score ===
        Building_Passenger_Lift,
        ROUND(passenger_lift_score,3) AS Passenger_Lift_Score,
        (w_passenger_lift * passenger_lift_score) AS Passenger_Lift_Score_Weighted,

        Building_Service_Lift,
        ROUND(service_lift_score,3) AS Service_Lift_Score,
        (w_service_lift * service_lift_score) AS Service_Lift_Score_Weighted,

        -- === Building year raw + score ===
        Built_Complete,
        Last_Renovate,
        ROUND(building_age_score,3) AS Building_Age_Score,
        (w_building_age * building_age_score) AS Building_Age_Score_Weighted,

        -- === Train station distance raw + score ===
        Distance_from_nearest_station,
        ROUND(train_station_score,3) AS Train_Station_Score,
        (w_train_station * train_station_score) AS Train_Station_Score_Weighted,

        -- === Facilities raw + score ===
        F_Services_Bank,
        ROUND(bank_score,3) AS Bank_Score,
        (w_fac_bank * bank_score) AS Bank_Score_Weighted,

        F_Food_Cafe,
        ROUND(cafe_score,3) AS Cafe_Score,
        (w_fac_cafe * cafe_score) AS Cafe_Score_Weighted,

        F_Food_Restaurant,
        ROUND(restaurant_score,3) AS Restaurant_Score,
        (w_fac_restaurant * restaurant_score) AS Restaurant_Score_Weighted,

        F_Food_Foodcourt,
        ROUND(foodcourt_score,3) AS Foodcourt_Score,
        (w_fac_foodcourt * foodcourt_score) AS Foodcourt_Score_Weighted,

        F_Food_Market,
        ROUND(market_score,3) AS Market_Score,
        (w_fac_market * market_score) AS Market_Score_Weighted,

        F_Retail_Conv_Store,
        ROUND(conv_store_score,3) AS Conv_Store_Score,
        (w_fac_conv_store * conv_store_score) AS Conv_Store_Score_Weighted,

        F_Services_Pharma_Clinic,
        ROUND(pharma_clinic_score,3) AS Pharma_Clinic_Score,
        (w_fac_pharma_clinic * pharma_clinic_score) AS Pharma_Clinic_Score_Weighted,

        F_Others_EV,
        ROUND(ev_score,3) AS EV_Score,
        (w_fac_ev * ev_score) AS EV_Score_Weighted,

        -- === TOTAL weighted score ===
        ROUND(
            (w_size           * size_score)
        + (w_floor          * floor_score)
        + (w_dir            * direction_score)
        + (w_ceiling        * ceiling_score)
        + (w_columns        * columns_score)
        + (w_bathroom       * bathroom_score)
        + (w_pantry         * pantry_score)
        + (w_deposit        * deposit_score)
        + (w_advance        * advance_score)
        + (w_common_pantry  * common_pantry_score)
        + (w_security       * security_score)
        + (w_passenger_lift * passenger_lift_score)
        + (w_service_lift   * service_lift_score)
        + (w_building_age   * building_age_score)
        + (w_train_station  * train_station_score)
        + (w_fac_bank       * bank_score)
        + (w_fac_cafe       * cafe_score)
        + (w_fac_restaurant * restaurant_score)
        + (w_fac_foodcourt  * foodcourt_score)
        + (w_fac_market     * market_score)
        + (w_fac_conv_store * conv_store_score)
        + (w_fac_pharma_clinic * pharma_clinic_score)
        + (w_fac_ev         * ev_score)
        ,3) AS Total_Score

        FROM scored
        ORDER BY Total_Score DESC
        LIMIT 200
        """

if sql:
    try:
        df = pd.read_sql(query, connection)
        df.to_csv(save_file, index=False, encoding='utf-8-sig')
        print("CSV saved successfully.")
    
    except Exception as e:
        print(f'Error: {e}')
    
    finally:
        cursor.close()
        connection.close()