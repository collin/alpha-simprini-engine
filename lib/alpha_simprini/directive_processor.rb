require "sprockets"
require "sprockets/directive_processor"

class AlphaSimprini::DirectiveProcessor < Sprockets::DirectiveProcessor
  def glob_assets(path, globstring)
    root = pathname.dirname.join(path).expand_path
    root.to_s.match(/(javascripts|stylesheets|images)/)
    asset_dir = $1

    asset_dirs = (::Rails::Engine.subclasses << Rails.application).map do |engine|
      engine.paths["app/assets"].map do |asset_path|
        engine.root.join(asset_path).join(asset_dir).join(path)
      end
    end.flatten

    Dir["{#{asset_dirs.join ','}}#{globstring}"]
  end

  # `require_directory` requires all the files inside a single
  # directory. It's similar to `path/*` since it does not follow
  # nested directories.
  #
  #     //= require_directory "./javascripts"
  #
  def process_require_directory_directive(path = ".")
    if relative?(path)
      
      root = pathname.dirname.join(path).expand_path
      unless root.directory?
        raise ArgumentError, "require_tree argument must be a directory"
      end
      context.depend_on(root)

      glob_assets(path, "/*").sort.each do |filename| #Dir["#{root}/*"].sort.each do |filename|
        if filename == self.file
          next
        elsif context.asset_requirable?(filename)
          context.require_asset(filename)
        end
      end
    else
      # The path must be relative and start with a `./`.
      raise ArgumentError, "require_directory argument must be a relative path"
    end
  end

  # `require_tree` requires all the nested files in a directory.
  # Its glob equivalent is `path/**/*`.
  #
  #     //= require_tree "./public"
  #
  def process_require_tree_directive(path = ".")
    if relative?(path)
      root = pathname.dirname.join(path).expand_path
      
      unless root.directory?
        raise ArgumentError, "require_tree argument must be a directory"
      end

      context.depend_on(root)
      
      
    glob_assets(path, "/**/*").sort.each do |filename| #Dir["{#{root},#{relative_root}}/**/*"].sort.each do |filename|
        if filename == self.file
          next
        elsif File.directory?(filename)
          context.depend_on(filename)
        elsif context.asset_requirable?(filename)
          context.require_asset(filename)
        end
      end
    else
      # The path must be relative and start with a `./`.
      raise ArgumentError, "require_tree argument must be a relative path"
    end
  end
end                                      
