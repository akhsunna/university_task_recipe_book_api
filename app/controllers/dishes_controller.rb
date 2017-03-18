class DishesController < ApplicationController
  include Rails::Pagination
  PER_PAGE = 15

  def index
    dishes = Dish.order_by_name

    filtering_params(params).each do |key, value|
      dishes = dishes.public_send(key, value) if value.present?
    end

    if params[:by_ingredients].present?
      dishes = dishes.reject do |dish|
        res = false
        params[:by_ingredients].each do |ingredient_id|
          res = true unless dish.dish_ingredients.pluck(:ingredient_id).include?(ingredient_id.to_i)
        end
        res
      end
    end

    if params[:page].present?
      current_page = params[:page].to_i
      dishes = paginate dishes, per_page: PER_PAGE
      next_page = current_page * PER_PAGE >= dishes.count ? current_page : current_page + 1
    end

    render json: {
      data: ActiveModel::Serializer::CollectionSerializer.new(
        dishes,
        each_serializer: DishSerializer
      ),
      next_page: next_page
    }
  end

  private

  def filtering_params(params)
    params.slice(
      :order_by,
      :by_category,
      :by_ingredients
    )
  end
end
