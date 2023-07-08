------------------------------------------------------------------------
-- Tạo bảng "Thời gian máy chạy & dừng"
------------------------------------------------------------------------

WITH X AS (
    SELECT
        cd,
        mmtb,
        CAST(ngay AS DATE) ngay,
        tg_chay,
        (tg_nghi + tg_hong + tg_sua + tg_trong) tg_dung,
        note
    FROM ODS.dbo.FACT_BANGKEMAYMOC_MES
)
SELECT
    cd,
    mmtb,
    ngay,
    SUM(tg_chay) tg_chay,
    SUM(tg_dung) tg_dung,
    note
INTO ODS.dbo.SX_Daily_MMTB
FROM X
GROUP BY cd,
    mmtb,
    ngay,
    note

