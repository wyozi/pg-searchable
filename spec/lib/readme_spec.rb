describe "README examples" do
  it "pass" do
    content = File.read('README.md')
    matches = content.scan(/```ruby(.+?)```/m)

    matches.each do |match|
      c = match[0]
      index = Regexp.last_match.offset(0).first
      line = content[..index].lines.count
      eval(c, binding, "README.md", line)
    end
  end
end