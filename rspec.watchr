watch( 'app/(.*)/(.*)' ) do |md|
  original_file = md[0]
  folder = md[1]
  file = md[2]
  run_rspec build_spec_file(folder, file), original_file
end

watch( 'spec/.*' ) do |md| 
  run_rspec md.to_s
end

def build_spec_file(folder, file) 
  ext = File.extname file
  base = File.basename file, ext
  "spec/#{folder}/#{base}_spec.rb"
end

def run_rspec(spec_file=nil, original_file=nil)
  puts " "
  if !File.exist? spec_file
    puts "Specs Not Found For:\n#{original_file}"
    puts " "
    puts "Looking For Spec File:\n#{spec_file}"
    return
  end

  puts "Running Specs: #{spec_file}"
  puts " "

  command = "rspec -fd "
  command << "#{spec_file}" if spec_file

  system(command) 
end

run_rspec "spec/"

Signal.trap 'INT' do
  exit
end
