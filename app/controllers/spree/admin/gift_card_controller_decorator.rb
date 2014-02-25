module Spree
  module Admin
    class GiftCardsController.class_eval do
      before_filter :assign_admin_generated, only: [:update, :create]

      def index
        params[:q] ||= {}
        @show_only_completed = params[:q][:completed_at_not_null] == '1'
        params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'

        @show_only_admin_generated = params[:q][:admin_generated_not_null] == '1'
        params[:q][:s] ||= @show_only_admin_generated

        created_at_gt = params[:q][:created_at_gt]
        created_at_lt = params[:q][:created_at_lt]

        if !params[:q][:created_at_gt].blank?
          params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
        end

        if !params[:q][:created_at_lt].blank?
          params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
        end

        if @show_only_completed or @show_only_admin_generated
          params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
          params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
        end

        @search = Spree::GiftCard.accessible_by(current_ability, :index).ransack(params[:q])
        @gift_cards = @search.result(distinct: true).includes([:transactions]).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:orders_per_page])
      end

      private

      def collection
        super.order("spree_gift_cards.created_at desc").page(params[:page]).per(Spree::Config[:orders_per_page])
      end

      def assign_admin_generated
        @object.admin_generated = params[object_name].delete(:admin_generated)
      end

    end
  end
end
