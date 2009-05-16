module Rip
  module UI
    def ui
      @ui ||= Console.new
    end

    class Console
      def error(message)
        puts message
        exit 1
      end

      def puts(message)
        super "ripenv: #{message}"
      end
    end
  end
end
