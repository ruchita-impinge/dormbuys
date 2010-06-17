class Files::FileManager

  #location of all product files on the server
  LOCAL_FILE_REPOSITORY = "#{PRODUCT_FILE_STORE}"
  
  #location of all product files through a URL
  WEB_FILE_REPOSITORY  = "#{APP_CONFIG['filesystem']['web_files_path']}"
  
  #location of all the shipping labels on the server
  LOCAL_LABEL_REPOSITORY = "#{SHIP_LABELS_STORE}"
  
  #location of all shipping labels through a URL
  WEB_LABEL_REPOSITORY = "#{APP_CONFIG['filesystem']['web_labels_path']}"


  ##
  # Function to test if file format is of acceptable type.
  # Acceptable Types:  PDF
  #
  # * @param file - File who's type will be tested
  # * @return Boolean T||F on validity
  ##
  def self.valid_file_format(file)
  
    #get the file content type
    ct = file.content_type.chomp
    
    #see if it is acceptable
    if  ct == 'application/pdf' then
      true
    else
      false
    end
  
  end #end valid_file_format
  
  
  ###
  # method to generate a filename
  ###
  def self.generate_file_name(file)
    
    #get the original filename
    file_name = file.original_filename
  
    #get the temp file
    tmp_file = file.local_path

    # get only the filename, not the whole path (from IE)
    new_filename = File.basename(file_name) 
  
    # replace all none alphanumeric, underscore or perioids with underscore
    new_filename.gsub!(/[^\w\.\_]/,'_') 
  
    #get a random number
    random = rand(100000)
  
    #final name for the file
    final_filename = "#{random}_#{new_filename}"
    
  end #end method generate_file_name(file)
  
  
  ###
  # method to save a file
  ###
  def self.save_file(file, fname=nil)
  
    #get the original filename
    file_name = file.original_filename
  
    #get the temp file
    tmp_file = file.local_path

    unless fname
      
      # get only the filename, not the whole path (from IE)
      new_filename = File.basename(file_name) 
    
      # replace all none alphanumeric, underscore or perioids with underscore
      new_filename.gsub!(/[^\w\.\_]/,'_') 
    
      #get a random number
      random = rand(100000)
    
      #final name for the file
      final_filename = "#{random}_#{new_filename}"
      
    else
      final_filename = fname
    end
    
    
    #get the file path
    new_filepath = "#{self::LOCAL_FILE_REPOSITORY}"
  
    #make the new path if necessary
    FileUtils.mkdir_p new_filepath
  
    #write out the file
    f = File.new("#{new_filepath}/#{final_filename}", "wb")
    f.write File.new(tmp_file).read
    f.close
    
    #return the image name
    return final_filename
    
  end #end save_file
  
  
  
  ##
  # method to take a temp file and save it to the shipping label
  # repository, and return its web accessable file name.
  #
  # * @param TempFile tmp_file - temp file for the label
  # * @return String - web path of the saved image
  ##
  def self.save_shipping_label(tmp_file)
    
    new_filename = "fedex_label"

    #get a random number
    random = rand(100000000)

    #final name for the file
    final_filename = "#{random}_#{new_filename}.pdf"

    #get the file path
    new_filepath = "#{self::LOCAL_LABEL_REPOSITORY}"

    #make the new path if necessary
    FileUtils.mkdir_p new_filepath

    #write out the file
    f = File.new("#{new_filepath}/#{final_filename}", "wb")
    f.write File.new(tmp_file).read
    f.close

    #return the image name
    final_filename

  end #end self.save_shipping_label
  
  
  
  
  ##
  # Function to copy an existing file on the filesystem and return the web accessable
  # path to the newly created file
  #
  # * @param filename - filename of the image to copy
  # * @return - newly created file's web accessable path
  ##
  def self.copy_existing_file(filename)
  
    #get a random num for the f_name
    random = rand(100000)
    
    #create a new file name
    new_filename = "#{random}" + filename[filename.index('_'), filename.length]
    
    #get the file path
    new_filepath = "#{self::LOCAL_FILE_REPOSITORY}"
  
    #make the new path if necessary
    FileUtils.mkdir_p new_filepath
  
    #copy the source to the destination
    src = "#{self::LOCAL_FILE_REPOSITORY}/#{filename}"
    dest = "#{new_filepath}/#{new_filename}"
    
    FileUtils.cp src, dest
  
    #return new filename
    new_filename
  
  end #end copy_existing_file




end #end class Files::FileManager
