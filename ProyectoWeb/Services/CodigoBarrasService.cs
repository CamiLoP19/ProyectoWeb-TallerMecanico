using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using ZXing;
using ZXing.Common;

namespace ProyectoWeb.Services
{
    public class CodigoBarrasService
    {
        private readonly ILogger<CodigoBarrasService> _logger;

        public CodigoBarrasService(ILogger<CodigoBarrasService> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Genera un código de barras en formato Base64
        /// </summary>
        public string GenerarCodigoBarrasBase64(string texto)
        {
            try
            {
                var writer = new BarcodeWriterPixelData
                {
                    Format = BarcodeFormat.CODE_128,
                    Options = new EncodingOptions
                    {
                        Height = 100,
                        Width = 400,
                        Margin = 10,
                        PureBarcode = false
                    }
                };

                var pixelData = writer.Write(texto);

                using (var bitmap = new Bitmap(pixelData.Width, pixelData.Height, PixelFormat.Format32bppRgb))
                using (var ms = new MemoryStream())
                {
                    var bitmapData = bitmap.LockBits(
                        new Rectangle(0, 0, pixelData.Width, pixelData.Height),
                        ImageLockMode.WriteOnly,
                        PixelFormat.Format32bppRgb);

                    try
                    {
                        // Copiar los datos del pixel
                        System.Runtime.InteropServices.Marshal.Copy(
                            pixelData.Pixels, 0, bitmapData.Scan0, pixelData.Pixels.Length);
                    }
                    finally
                    {
                        bitmap.UnlockBits(bitmapData);
                    }

                    bitmap.Save(ms, ImageFormat.Png);
                    byte[] imageBytes = ms.ToArray();
                    return Convert.ToBase64String(imageBytes);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al generar código de barras");
                return string.Empty;
            }
        }
    }
}
