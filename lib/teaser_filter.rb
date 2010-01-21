class TeaserFilter < Nanoc3::Filter 
  identifier :teaser
  def run(content, params={})
    content.split(/<!--\s*teaser\s*-->/i).first
  end
end

class RemoveTeaserTagFilter < Nanoc3::Filter 
  identifier :remove_teaser_tag
  def run(content, params={})
    content.split(/<!--\s*teaser\s*-->/i).join
  end
end
