module ActionDispatch::Routing
  class Mapper
    def birja_kreditov_response options = {}
      block = Proc.new do
        post :update_info, to: 'birja_kreditov#update_info'
      end

      if options[:without_namespace]
        block.call
      else
        scope :"#{ BirjaKreditov.route_scope }", as: :birja_kreditov, &block
      end
    end
  end
end
