require 'render_anywhere'

module PdfGenerator
  class Download
    include RenderAnywhere

    def initialize(profile)
      @profile = profile
    end

    def to_pdf
      kit = PDFKit.new(as_html)
      kit.to_file("tmp/profile_#{profile.id}.pdf")
    end

    def filename
      "zgloszenie_#{profile.first_name}_#{profile.last_name}.pdf"
    end

    private

    attr_reader :profile

    def as_html
      render template: "profiles/show",
        layout: 'pdf',
        locals: { profile: profile }
    end
  end
end
