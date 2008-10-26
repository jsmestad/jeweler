class Jeweler
  module Gemspec
    # Writes out the gemspec
    def write_gemspec
      self.refresh_version
      @gemspec.version = self.version
      @gemspec.date = Time.now
      File.open(gemspec_path, 'w') do |f|
        f.write @gemspec.to_ruby
      end
      puts "Generated: #{gemspec_path}"
    end
    
    # Validates the gemspec in an environment similar to how GitHub would build
    # it. See http://gist.github.com/16215
    def validate_gemspec
      begin
        parse_gemspec
        puts "#{gemspec_path} is valid."
      rescue Exception => e
        puts "#{gemspec_path} is invalid. See the backtrace for more details."
        raise
      end
    end
    
    
    def valid_gemspec?
      begin
        parse_gemspec
        true
      rescue Exception => e
        false
      end
    end
    
    def parse_gemspec(data = nil)
      data ||= File.read(gemspec_path)
      Thread.new { eval("$SAFE = 3\n#{data}", binding, gemspec_path) }.join
    end
    
  protected
    def gemspec_path
      denormalized_path = File.join(@base_dir, "#{@gemspec.name}.gemspec")
      absolute_path = File.expand_path(denormalized_path)
      absolute_path.gsub(Dir.getwd + File::SEPARATOR, '')
    end
  end
end