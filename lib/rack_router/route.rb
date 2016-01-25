class Route
  attr_reader :method,
              :path,
              :matchers_chain

  def initialize(args)
    @method = args[:method]
    @path = args[:path]
    @matchers_chain = build_chain(chain_objs)
  end

  def matches_request?(request)
    matchers_chain.run_chain(request)
  end

  private

  def build_chain(objs)
    objs[0..-2].each_with_index do |obj, index|
      obj.next_obj = objs[index+1]
    end

    objs.first
  end

  def chain_objs
    [
      path_matcher,
      MethodMatcher.new(method)
    ]
  end

  def path_matcher
    if path.include?(':')
      ParametrizedPathMatcher.new(path)
    else
      ExactPathMatcher.new(path)
    end
  end



  module MatcherChainOfResponsibility
    attr_accessor :next_obj

    def run_chain(request)
      matches_request?(request) && call_next(request)
    end

    def call_next(request)
      if next_obj.nil?
        true
      else
        next_obj.run_chain(request)
      end
    end
  end

  class ExactPathMatcher
    include MatcherChainOfResponsibility

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

  class ParametrizedPathMatcher
    include MatcherChainOfResponsibility

    PARAMS_FINDER_REGEXP = /(:[^\/]+)/.freeze
    PARAMS_REPLACEMENT_REGEXP = '[^\/]+'.freeze

    def initialize(path)
      @path_regexp = Regexp.new(build_path_regexp_string(path))
    end

    def matches_request?(request)
      @path_regexp.match(prepare(request.path))
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
    include MatcherChainOfResponsibility

    def initialize(method)
      @method = method
    end

    def matches_request?(request)
      request.method == @method
    end
  end
end
