require 'detroit/tool'

module Detroit

  # Create new RSpec tool with specified +options+.
  def RSpec(options={})
    RSpec.new(options)
  end

  # The RSpec tool is used to run project specifications
  # written with RSpec. Specifications are expected to found
  # in the standard `spec/` directory unless otherwise specified
  # in the tools options.
  #
  # Options:
  #
  #   specs     File glob(s) of spec files. Defaults to ['spec/**/*_spec.rb', 'spec/**/spec_*.rb'].
  #   loadpath  Paths to add $LOAD_PATH. Defaults to ['lib'].
  #   live      Ignore loadpath, use installed libraries instead. Default is false.
  #   require   Lib(s) to require before excuting specifications.
  #   warning   Whether to show warnings or not. Default is false.
  #   format    Format of RSpec output.
  #   extra     Additional commandl ine options for spec command.
  #
  # NOTE: This tool currently shells out to the command line.
  #
  #--
  # TODO: Use rspec options file?
  #
  # TODO: RCOV suppot?
  #   ruby [ruby_opts] -Ilib -S rcov [rcov_opts] bin/spec -- examples [spec_opts]
  #++
  class RSpec < Tool

    # File glob(s) of spec files. Defaults to ['spec/**/*_spec.rb', 'spec/**/spec_*.rb'].
    attr_accessor :specs

    # A more generic alternative to #specs.
    alias_accessor :include, :specs

    # Paths to add $LOAD_PATH. Defaults to ['lib'].
    attr_accessor :loadpath

    # Ignore loadpath, use installed libraries instead. Default is false.
    #attr_accessor :live

    # Scripts to require before excuting specifications.
    attr_accessor :requires

    # Whether to show warnings or not. Default is false.
    attr_accessor :warning

    # Format of RSpec output.
    attr_accessor :format

    # Output file, STDOUT if nil.
    attr_accessor :output

    # Additional command line options for rspec.
    attr_accessor :extra


    #  A S S E M B L Y  M E T H O D S

    #
    def assemble?(station, options={})
      case station
      when :test then true
      end
    end

    # Attach test method to test assembly.
    #
    # @todo Attach documentaton?
    def assemble(station, options={})
      case station
      #when :document then document
      when :test     then run
      end
    end


    #  S E R V I C E  M E T H O D S

    # Run all specs.
    #
    # Returns +false+ if any tests failed, otherwise +true+.
    def run
      run_specs
    end

    #
    alias_method :test, :run

    # Run all specs with documentation output.
    def document
      run_specs('documentation')
    end

  private

    #
    def initialize_defaults
      @loadpath = metadata.loadpath

      @specs    = ['spec/**/*_spec.rb', 'spec/**/spec_*.rb']
      @requires = []
      @warning  = false
    end

    # Run rspecs.
    def run_specs(format=nil)
      format   = format || self.format
      specs    = self.specs.to_list
      loadpath = self.loadpath.to_list
      requires = self.requires.to_list

      files = multiglob(*specs)

      if files.empty?
        puts "No specifications."
      else
        # ruby [ruby_opts] -Ilib bin/spec examples [spec_opts]
        argv = []
        argv << "-w" if warning
        argv << %[-I"#{loadpath.join(':')}"] unless loadpath.empty?
        argv << %[-r"#{requires.join(':')}"] unless requires.empty?
        argv << %[-f"#{format}"] if format
        argv << %[-o"#{output}"] if output
        argv << files
        argv << extra_options

        argv = argv.flatten

        trace "rspec " + argv.join(' ')

        success = ::RSpec::Core::Runner.run(argv)
      end
    end

    # Extra options.
    def extra_options
      case extra
      when String
        extra.split(/\s+/)
      when Array
        extra
      else
        []
      end
    end

    #
    def initialize_requires
      require 'rspec/core'
    end

  public

    def self.man_page
      File.dirname(__FILE__)+'/../man/detroit-rspec.5'      
    end

  end

end
