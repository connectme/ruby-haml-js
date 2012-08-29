require 'tilt/template'

module RubyHamlJs
  class Template < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      defined? ::ExecJS
    end

    def initialize_engine
      require_template_library 'execjs'
    end

    def prepare
    end

    # Compiles the template using HAML-JS
    #
    # Returns a JS function definition String. The result should be
    # assigned to a JS variable.
    #
    #     # => "function(data) { ... }"
    def evaluate(scope, locals, &block)
      compile_to_function
    end



    private

    def compile_to_function
      function = ExecJS.
        compile(self.class.haml_source).
        eval "Haml('#{js_string data}', {escapeHtmlByDefault: true, customErrorEscape: #{js_custom_error_escape}, customEscape: #{js_custom_escape}}).toString()"
      # make sure function is annonymous
      function.sub /function \w+/, "function "
    end

    def js_string str
      (str || '').
        gsub("'")  {|m| "\\'" }.
        gsub("\n") {|m| "\\n" }
    end

    def js_custom_error_escape
      func = self.class.custom_error_escape
      func ? "'#{js_string func}'" : 'null'
    end

    def js_custom_escape
      escape_function = self.class.custom_escape
      escape_function ? "'#{js_string escape_function}'" : 'null'
    end

    class << self
      attr_accessor :custom_escape, :custom_error_escape

      def haml_source
        # Haml source is an asset
        @haml_source ||= IO.read File.expand_path('../../../vendor/assets/javascripts/haml.js', __FILE__)
      end

    end

  end
end

