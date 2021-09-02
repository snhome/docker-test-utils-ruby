require 'yaml'
require 'optparse'

class String
    def numeric?
      Float(self) != nil rescue false
    end

    def numeric!
     self.include?('.') ? self.to_f : self.to_i
    end

    def smart_cast
        not_num = self.start_with?("'") || self.start_with?('"') || !self.numeric?
        not_num ? self : self.numeric!
    end
end

class Hash
    def set_by_path(path, val)
        paths = path.split(".")
        success = false
        paths.inject(self) do |hash, key|
            return unless hash.key? key
            unless hash[key].instance_of? Hash
                hash[key] = val
                success = true
            end
            hash[key]
        end
        success
    end

    def get_by_path(path)
        path.split(".").inject(self) do |hash, key|
            return unless hash.key? key
            hash[key]
        end
    end
end

def get_files_with_glob(files)
    arr = []
    files.each do |f| 
       f.include?('*') ? arr.push(*Dir.glob(f)) : arr.push(f)
    end
    arr
end

def elements_parse!(elements)
    elements.map! do |element|
        e = element.split('=').map {|e| e.strip } 
        {path: e[0], val: e[1]&.smart_cast}
    end
end

Options = Struct.new(:elements, :files, :accept_empty)
args = Options.new()

OptionParser.new do |opts|
    args.elements = []
    opts.banner = 'Usage: yml_edit.rb [options]'
    opts.on("--empty", "--[no-]empty [FLAG]", TrueClass, "can set empty value") do |v|
        args.accept_empty = v.nil? ? true : v
    end
    opts.on('-e', '--elements element1 element2 element3', Array, 
            'ex: test.username=root ') do |e|
      args.elements |= [*e]
    end
    opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
end.parse!
args.files = ARGV
puts('No any files') and exit if !args.files
elements_parse!(args.elements)
args.elements.reject! {|e| e[:val].nil? } unless args.accept_empty
yml_files = get_files_with_glob(args.files)
yml_files.each do |file|
    dict = YAML.load_file(file)
    success_count = 0
    args.elements.each do |e| 
        success = dict.set_by_path(e[:path], e[:val])
        success_count += 1 if success
    end
    puts "File: #{file}, edited #{success_count}"
    File.open(file, 'w') {|f| f.write dict.to_yaml }
end
