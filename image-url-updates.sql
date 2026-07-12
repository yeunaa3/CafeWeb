/* ======================================================================
   IMAGE URL ONLINE FIX 2026-07-12
   Đổi đường dẫn ảnh local trong database sang raw GitHub URL để máy khác vẫn hiển thị ảnh.
   Lưu ý: các file ảnh trong web/images phải được commit và push lên GitHub trước.
   ====================================================================== */
DECLARE @ImageBase VARCHAR(255) = 'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web';

UPDATE dbo.Products
SET image_url = CASE
    WHEN image_url LIKE '/images/products/%' THEN @ImageBase + image_url
    WHEN image_url LIKE 'images/products/%' THEN @ImageBase + '/' + image_url
    WHEN image_url LIKE '/uploads/products/%' THEN @ImageBase + '/images/products' + image_url
    WHEN image_url LIKE 'uploads/products/%' THEN @ImageBase + '/images/products/' + image_url
    ELSE image_url
END
WHERE image_url IS NOT NULL
  AND image_url <> ''
  AND image_url NOT LIKE 'http://%'
  AND image_url NOT LIKE 'https://%';

UPDATE dbo.Users
SET avatar_url = CASE
    WHEN avatar_url LIKE '/images/avatars/%' THEN @ImageBase + avatar_url
    WHEN avatar_url LIKE 'images/avatars/%' THEN @ImageBase + '/' + avatar_url
    WHEN avatar_url LIKE '/uploads/avatars/%' THEN @ImageBase + '/images/avatars' + avatar_url
    WHEN avatar_url LIKE 'uploads/avatars/%' THEN @ImageBase + '/images/avatars/' + avatar_url
    ELSE avatar_url
END
WHERE avatar_url IS NOT NULL
  AND avatar_url <> ''
  AND avatar_url NOT LIKE 'http://%'
  AND avatar_url NOT LIKE 'https://%';