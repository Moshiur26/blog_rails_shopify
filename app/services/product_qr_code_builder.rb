# frozen_string_literal: true

require "rqrcode"

class ProductQrCodeBuilder
  class << self
    def svg_for_url(url)
      qrcode = RQRCode::QRCode.new(url)

      qrcode.as_svg(
        color: "000",
        shape_rendering: "crispEdges",
        module_size: 5,
        standalone: true,
        use_path: true
      )
    end
  end
end
