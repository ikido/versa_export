xml.instruct!
xml.products do
  @products.each do |p|
    xml.product do
      xml.aid p.id
      xml.title [p.title, p.subtitle].join(' ')
      xml.desc strip_tags(p.description_html)
      xml.price p.price
      xml.link p.url
      xml.brand p.vendor
      xml.shop_cat p.category
      xml.image p.featured_image_url
    end
  end
end
