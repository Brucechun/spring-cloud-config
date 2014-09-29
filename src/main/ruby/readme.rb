module SpringCloud
  module Build

    IncludeDirectiveRx = /^\\?include::([^\[]+)\[(.*?)\]$/

    class << self

      def process_include out, src, target, attrs
        unless target.start_with?('/')
          target = File.new(File.join(src, target))
        else
          target = File.new(target)
        end
        target.each do |line|
          self.process(out, File.dirname(target), line)
        end
      end

      def process out, src, line
        if ((escaped = line.start_with?('\\include::')) || line.start_with?('include::')) && (match = IncludeDirectiveRx.match(line))
          if escaped
            out << line[1..-1]
          else
            self.process_include out, src, match[1], match[2].strip
          end
        else
          out << line
        end
      end

      def render_file file, options = {}

        srcDir = File.dirname(file)
        out = []
        File.new(file).each do |line|
          self.process(out, srcDir, line)
        end

        unless options[:to_file]
          puts out
        else
          writer = File.new(options[:to_file],'w+')
          out.each { |line| writer.write(line) }
        end

      end

    end

  end
end
