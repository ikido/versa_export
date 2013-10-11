class ProductsExport
  include SuckerPunch::Job

  def perform(site, xml_file_path)
    ActiveRecord::Base.connection_pool.with_connection do
      controller = ExportsController.new
      VersacommerceAPI::Base.site = site # dunno why this gets reset

      total_products = get_total_products

      @products = []
      offset = 0
      limit = 40

      begin
        current_products = get_products({
          offset: offset,
          limit: limit
        })

        @products = @products + current_products
        offset += limit
      end while @products.size < total_products

      File.open(xml_file_path, 'w') do |f|
        controller.instance_variable_set('@products', @products)
        f.write controller.render_to_string(
          action: 'products',
          formats: [:xml]
        )
      end
    end
  end

protected

  def get_total_products(retries=3)
    unless retries > 0
      raise VersacommerceAPI::ServiceUnreachable
    end

    retries -=1

    begin
      total_products = VersacommerceAPI::Product.count
    rescue
      sleep 5
      products = get_total_products(retries)
    end
  end

  def get_products(params={}, retries=3)
    unless retries > 0
      raise VersacommerceAPI::ServiceUnreachable
    end

    retries -=1

    begin
      total_products = VersacommerceAPI::Product.find(:all, params)
    rescue
      sleep 5
      products = get_products(params, retries)
    end
  end

end