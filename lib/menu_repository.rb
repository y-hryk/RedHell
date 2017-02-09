module Menu_repository
  class API < Grape::API
    # APIアクセスに接頭辞を付加
    # ex) http://localhost:3000/api
    prefix "api"

    # APIアクセスにバージョン情報を付加
    # ex) http://localhost:3000/api/v1
    version 'v1', :using => :path, parameter: "kind_id"
    format :json

    resource "menus" do
      # ex) http://localhost:3000/api/v1/menus
      # ex) http://localhost:3000/api/v1/menus?kind=1
      desc "returns all Menus"

      get do
        menus = []
        if params[:kind_id]
          menus = Menu.where(kind_id: params[:kind_id])
        else
          menus = Menu.all
        end
        {results: menus,
        total_results: menus.count}
      end

    end
  end
end
