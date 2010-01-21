class Nanoc3::Item
  def content(opts = {})
    opts[:rep] ||= :default
    opts[:snapshot] ||= :last
    reps.find { |r| r.name == opts[:rep] }.content_at_snapshot(opts[:snapshot])
  end

  def name
    identifier.split("/").last 
  end
end
