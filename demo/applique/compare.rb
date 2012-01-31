When 'should be clearly laid out as follows' do |text|
  text = text.sub('$0', File.basename($0))
  @out.strip.assert == text.strip
end
