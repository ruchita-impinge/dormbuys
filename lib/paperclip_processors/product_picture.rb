require 'RMagick'

module Paperclip
  class ProductPicture < Processor
    
    attr_accessor :current_geometry, :target_geometry, :format, :whiny, :convert_options, :source_file_options

    def initialize(file, options = {}, attachment = nil)
      super

      geometry             = options[:geometry]
      @file                = file
      @crop                = geometry[-1,1] == '#'
      @target_geometry     = Geometry.parse geometry
      @current_geometry    = Geometry.from_file @file
      @source_file_options = options[:source_file_options]
      @convert_options     = options[:convert_options]
      @whiny               = options[:whiny].nil? ? true : options[:whiny]
      @format              = options[:format]

      @current_format      = File.extname(@file.path)
      @basename            = File.basename(@file.path, @current_format)
      
    end #end initialize

    def make
      @file.pos = 0 # Reset the file position incase it is coming out of a another processor
      
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode
      
      begin
        safe_resize_file(dst)
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}" if @whiny
      end
      
      dst
    end #end make
    
    
    def safe_resize_file(destination)
      # => @file.rewind
      begin
        img = Magick::Image.from_blob(@file.read)[0]
      rescue
        raise PaperclipError, "Error creating composite image, no image was provided"
      end

      #get the options for resize
      width = @target_geometry.width
      height = @target_geometry.height
      matte_color = 'white'

      #create the matte
      matte = Magick::Image.new(width, height){ self.background_color = matte_color }
      matte.format = "jpg"

      #if image is smaller then requested dimensions already
      #and we don't want to scale up, skip resizing
      if !(img.columns <= width && img.rows <= height)

        #create the new size image
        img.change_geometry!("#{width}x#{height}") do |cols, rows, _img|
          _img.resize!(cols, rows)
        end
        new_img = img

      else

        #no resizing just use the image as is in small form
        new_img = img

      end

      #create and return the composite
      result = matte.composite(new_img, Magick::CenterGravity, Magick::OverCompositeOp)
      result.format = "jpg"
      
      #result.write("/Users/brian/Desktop/#{Time.now.to_s}.jpg")
      
      result.write(File.expand_path(destination.path))

    end #end method safe_resize_file
    
    
  end #end class
end #end modual
