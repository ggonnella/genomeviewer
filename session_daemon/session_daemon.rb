path = "../tmp/sessions/"
loop do
 Dir.new(path).entries.collect {|file_name|
  if (not file_name=="." and not file_name=="..")
   if (File.new(path+file_name).atime+(60*60*24) < (Time.now))
     File.delete(path+file_name)
   end
  end
  }
 sleep(1)
end