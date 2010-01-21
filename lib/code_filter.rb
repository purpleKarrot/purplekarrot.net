class CodeFilter < Nanoc3::Filter 

  identifier :code

  def run(content, params={})
    require 'coderay'

    # Check params
    raise ArgumentError, "CodeRay filter requires a :language argument which is missing" if params[:language].nil?

    # Get result
    "\n\n<div class=\"code-ray\"><pre>" + ::CodeRay.scan(content, params[:language]).html + "</pre></div>\n\n"
  end
end
