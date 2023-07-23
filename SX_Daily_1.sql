------------------------------------------------------------------------
-- Tạo bảng "Tiêu Hao raw"
------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#tieuhao_raw') IS NOT NULL
    DROP TABLE tempdb..#tieuhao_raw
SELECT
    'TIEUHAO' bang_goc ,
    so_phieu ,
    lsx ,
    sp ,
    x_product_code ,
    cd ,
    ngay ,
    ca ,
    ten_hang ,
    ma_nhom ,
    ma_hang ,
    nhom_sp ,
    dvt ,
    kho ,
    '-' pham_cap ,
    tt ,
    sl_qk,
    sl_tt
INTO #tieuhao_raw
FROM ODS.dbo.FACT_BANGKETIEUHAO_MES
WHERE cd like N'%Nghiền liệu%'

------------------------------------------------------------------------
-- Tạo bảng "Nhập Về raw"
------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#nhapve_raw') IS NOT NULL
    DROP TABLE tempdb..#nhapve_raw
SELECT
    'NHAPVE' bang_goc ,
    so_phieu ,
    lsx ,
    sp ,
    x_product_code ,
    cd ,
    ngay ,
    ca ,
    ten_hang ,
    ma_nhom ,
    ma_hang ,
    '-' nhom_sp ,
    dvt ,
    kho ,
    pham_cap ,
    tt ,
    sl,
    sl_sx
INTO #nhapve_raw
FROM ODS.dbo.FACT_BANGKENHAPTHANHPHAM_MES

------------------------------------------------------------------------
-- Tạo bảng "Tiêu Hao processed"
------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#tieuhao_processed') IS NOT NULL
    DROP TABLE tempdb..#tieuhao_processed
SELECT
	bang_goc ,
	so_phieu ,
	lsx ,
	sp ,
	x_product_code ,
	cd ,
	ngay ,
    ca ,
	ten_hang ,
	ma_nhom ,
	ma_hang ,
    nhom_sp ,
	dvt ,
	kho ,
	pham_cap ,
	tt ,
	ROUND(SUM(sl_qk),2) sl_th,
	ROUND(SUM(sl_tt),2) sl_kh
INTO #tieuhao_processed
FROM #tieuhao_raw
GROUP BY bang_goc , so_phieu , lsx , sp , x_product_code , cd , ngay , ca , ten_hang , ma_nhom , ma_hang , nhom_sp , dvt , kho , pham_cap , tt

------------------------------------------------------------------------
-- Tạo bảng "Nhập Về processed"
------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#nhapve_processed') IS NOT NULL
    DROP TABLE tempdb..#nhapve_processed
SELECT
	bang_goc ,
	so_phieu ,
	lsx ,
	sp ,
	x_product_code ,
	cd ,
	ngay ,
    ca ,
	ten_hang ,
	ma_nhom ,
	ma_hang ,
    nhom_sp ,
	dvt ,
	kho ,
	pham_cap ,
	tt ,
	ROUND(SUM(sl),2) sl_th,
	ROUND(SUM(sl_sx),2) sl_kh
INTO #nhapve_processed
FROM #nhapve_raw
GROUP BY bang_goc , so_phieu , lsx , sp , x_product_code , cd , ngay , ca , ten_hang , ma_nhom , ma_hang , nhom_sp , dvt , kho , pham_cap , tt

------------------------------------------------------------------------
-- Tạo bảng "SX_Daily_1"
------------------------------------------------------------------------
IF OBJECT_ID('ODS.dbo.SX_Daily_1') IS NOT NULL
    DROP TABLE ODS.dbo.SX_Daily_1;

IF OBJECT_ID('tempdb..#union_all') IS NOT NULL
    DROP TABLE tempdb..#union_all;
WITH X AS (
    SELECT * FROM #tieuhao_processed UNION ALL SELECT * FROM #nhapve_processed
),
Y AS (
    SELECT
        m.mmtb,
        X.*
    FROM X
    LEFT JOIN ODS.dbo.FACT_BANGKEMAYMOC_MES m 
        ON X.cd = m.cd
        AND X.ngay = m.ngay
        AND X.so_phieu = m.so_phieu
        AND X.lsx = m.lsx
        AND X.sp = m.sp
)

SELECT * 
INTO ODS.dbo.SX_Daily_1
FROM Y
