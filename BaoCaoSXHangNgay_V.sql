------------------------------------------------------------------------
-- Create temp Tieu Hao raw
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
    ten_hang ,
    ma_nhom ,
    ma_hang ,
    dvt ,
    kho ,
    '-' pham_cap ,
    tt ,
    sl_qk
INTO #tieuhao_raw
FROM ODS.dbo.FACT_BANGKETIEUHAO_MES
WHERE cd like N'%Nghiền liệu%'

------------------------------------------------------------------------
-- Create temp Nhap Ve raw
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
    ten_hang ,
    ma_nhom ,
    ma_hang ,
    dvt ,
    kho ,
    pham_cap ,
    tt ,
    sl
INTO #nhapve_raw
FROM ODS.dbo.FACT_BANGKENHAPTHANHPHAM_MES

------------------------------------------------------------------------
-- Create temp Tieu Hao processed
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
	ten_hang ,
	ma_nhom ,
	ma_hang ,
	dvt ,
	kho ,
	pham_cap ,
	tt ,
	ROUND(SUM(sl_qk),2) sl
INTO #tieuhao_processed
FROM #tieuhao_raw
GROUP BY bang_goc , so_phieu , lsx , sp , x_product_code , cd , ngay , ten_hang , ma_nhom , ma_hang , dvt , kho , pham_cap , tt

------------------------------------------------------------------------
-- Create temp Nhap Ve processed
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
	ten_hang ,
	ma_nhom ,
	ma_hang ,
	dvt ,
	kho ,
	pham_cap ,
	tt ,
	ROUND(SUM(sl),2) sl
INTO #nhapve_processed
FROM #nhapve_raw
GROUP BY bang_goc , so_phieu , lsx , sp , x_product_code , cd , ngay , ten_hang , ma_nhom , ma_hang , dvt , kho , pham_cap , tt

------------------------------------------------------------------------
-- Create BaoCaoSXHangNgay view
------------------------------------------------------------------------
IF OBJECT_ID('ODS.dbo.BaoCaoSXHangNgay_V') IS NOT NULL
    DROP VIEW dbo.BaoCaoSXHangNgay_V
SELECT *
INTO ODS.dbo.BaoCaoSXHangNgay_V
FROM (SELECT * FROM tempdb..#tieuhao_processed UNION ALL
      SELECT * FROM tempdb..#nhapve_processed)