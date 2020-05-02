class SearchStoryForm < ActiveType::Object

  attribute :search_string, :string
  attribute :order_column_name, :string
  attribute :order_direction, :string

  def self.default(arg)
    case arg
    when :search_string
      ""
    when :order_direction
      "desc"
    when :order_column_name
      "time_at_num_one"
    end
  end

  def fulfill
    Rails.logger.info "called fulfill"
    Rails.logger.info "self.search_string #{self.search_string}"
    Rails.logger.info "self.order_direction #{self.order_direction}"

    case @order_column_name.to_sym
    when nil
      SearchStory.search_description(self.search_string)
    when :time_at_num_one
      SearchStory.search_description_order_by_time_at_num_one(self.search_string, self.order_direction)
    when :last_seen
      SearchStory.search_description_order_by_date_seen(self.search_string, self.order_direction)
    else
      raise ArgumentError, "Story.search: bad arg 'order_column_name' #{order_column_name}"
    end
  end

  def initialize(args)
    @search_string = args.fetch(:search_string)
    @order_column_name = args.fetch(:order_column_name)
    @order_direction = args.fetch(:order_direction)
    super
  end

  def toggle_direction
    case @order_direction
    when nil
      self.order_direction = 'asc'
    when 'asc'
      self.order_direction = 'desc'
    when 'desc'
      self.order_direction = 'asc'
    end
  end

end
