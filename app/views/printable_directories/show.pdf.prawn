#pdf.font File.join(Rails.root, 'vendor/Cyberbit.ttf')

# cover page
pdf.move_down 200
pdf.text Setting.get(:name, :community) + "\n", :align => :center, :size => 24
pdf.text 'Directory', :align => :center, :size => 20
#if (logo = Setting.get(:appearance, :logo)).to_s.any?
#  pdf.move_down 25
#  pdf.image File.join(Rails.root, 'public/images', logo), :position => :center
#end
pdf.move_down 200
pdf.text "Created especially for #{@logged_in.name} on #{Date.today.strftime '%B %e, %Y'}", :size => 14, :align => :center

# directory pages
pdf.start_new_page

pdf.header([pdf.bounds.left, pdf.bounds.top], :height => 200) do
  pdf.text "#{Setting.get(:name, :community)} Directory\n", :size => 24
  pdf.move_down 5
  pdf.horizontal_rule
  pdf.stroke_line(0, 0, 0, 0) # FIXME: this is needed in order for horizontal_rule to work -- don't know why
end

alpha = nil

pdf.column_box [pdf.bounds.left, 670], :width => pdf.bounds.width, :columns => 2, :height => 640 do
  @families.each do |family|
    next unless family.mapable? or family.home_phone.to_i > 0
    pdf.bounds.move_past_bottom if pdf.y < 130
    if family.last_name[0..0] != alpha
  pdf.move_down 150 if pdf.y < 150
      alpha = family.last_name[0..0]
      pdf.text alpha + "\n", :size => 25
      pdf.horizontal_line pdf.bounds.left, pdf.bounds.left+pdf.bounds.width
      pdf.move_down 20
    end
    if family.has_photo?
      img = Prawn::Images::JPG.new(File.read(family.photo_large_path))
      w = img.width * 100 / img.height
      x = 538 - w
      pdf.image family.photo_medium_path, :at => [x, pdf.y-60], :height => 100, :position => :right
    end
    pdf.text family.name + "\n", :size => 18
    if family.people.length > 2
      p = family.people.map do |p|
        p.last_name == family.last_name ? p.first_name : p.name
      end.join(', ')
      pdf.text p + "\n", :size => 11
    end
    begin
      if family.share_address_with(@logged_in) and family.mapable?
        pdf.text family.address1 + "\n", :size => 14
        pdf.text family.address2 + "\n", :size => 14 if family.address2.to_s.any?
        pdf.text family.city + ', ' + family.state + '  ' + family.zip + "\n", :size => 14
      end
    rescue => e
      puts e.message, e.backtrace
    end
    pdf.text format_phone(family.home_phone), :size => 14 if family.home_phone.to_i > 0
    pdf.text "\n"
  end
end