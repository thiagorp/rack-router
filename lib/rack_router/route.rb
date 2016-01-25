class Route
  attr_reader :method,
              :path

  def initialize(args)
    @method = args[:method]
    @path = args[:path]
  end

  def matches_request?(request)
    matchers.all? do |matcher|
      matcher.matches_request?(request)
    end
  end

  private

  def matchers
    [
      path_matcher,
      MethodMatcher.new(method)
    ]
  end

  def path_matcher
    if ParameterizedPathMatcher.is_path_parameterized?(path)
      ParameterizedPathMatcher.new(path)
    else
      ExactPathMatcher.new(path)
    end
  end



  class ExactPathMatcher
    def initialize(path)
      @path = path
    end

    def matches_request?(request)
      prepare(request.path) == @path
    end

    private

    def prepare(path)
      if path[-1] == '/'
        path[0..-2] 
      else
        path
      end
    end
  end

  class ParameterizedPathMatcher
    PARAMS_FINDER_REGEXP = /(:[^\/]+)/.freeze
    PARAMS_REPLACEMENT_REGEXP = '[^\/]+'.freeze

    def initialize(path)
      @path_regexp = Regexp.new(build_path_regexp_string(path))
    end

    def matches_request?(request)
      @path_regexp.match(prepare(request.path))
    end

    def self.is_path_parameterized?(route)
      PARAMS_FINDER_REGEXP.match(route)
    end

    private

    def prepare(path)
      if path[-1] == '/'
        path[0..-2]
      else
        path
      end
    end

    def build_path_regexp_string(path)
      '^' + path.sub(PARAMS_FINDER_REGEXP, PARAMS_REPLACEMENT_REGEXP) + '$'
    end
  end

  class MethodMatcher
    def initialize(method)
      @method = method
    end

    def matches_request?(request)
      request.method == @method
    end
  end
end
