module Synthesis
  module AssetPackageHelper
    
    def should_merge?
      AssetPackage.merge_environments.include?(Rails.env)
    end

    def javascript_include_merged(*sources)
      options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }

      if sources.include?(:defaults) 
        sources = sources[0..(sources.index(:defaults))] + 
          ['prototype', 'effects', 'dragdrop', 'controls'] + 
          (File.exists?("#{Rails.root}/public/javascripts/application.js") ? ['application'] : []) + 
          sources[(sources.index(:defaults) + 1)..sources.length]
        sources.delete(:defaults)
      end

      sources.collect!{|s| s.to_s}
      sources = (should_merge? ? 
        AssetPackage.targets_from_sources("javascripts", sources) : 
        AssetPackage.sources_from_targets("javascripts", sources))
        
      javascript_tags = sources.collect {|source| javascript_include_tag(source, options) }.join("\n")
      return javascript_tags.html_safe if javascript_tags.respond_to?(:html_safe)
      return javascript_tags
    end

    def stylesheet_link_merged(*sources)
      options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }

      sources.collect!{|s| s.to_s}
      sources = (should_merge? ? 
        AssetPackage.targets_from_sources("stylesheets", sources) : 
        AssetPackage.sources_from_targets("stylesheets", sources))

      stylesheet_tags = sources.collect { |source| stylesheet_link_tag(source, options) }.join("\n")
      return stylesheet_tags.html_safe if stylesheet_tags.respond_to?(:html_safe)
      return stylesheet_tags
    end

  end
end