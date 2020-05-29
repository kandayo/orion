class Orion::Handlers::RouteFinder
  include HTTP::Handler

  @tree : Orion::DSL::Tree

  def initialize(@tree : Orion::DSL::Tree)
  end

  def call(cxt : HTTP::Server::Context)
    leaf = nil
    path = cxt.request.path
    @tree.search(path.rchop(File.extname(path))) do |result|
      unless leaf
        cxt.request.path_params = result.params
        cxt.request.format = File.extname(path)
        leaf = result.payloads.find &.matches_constraints? cxt.request
        leaf.try &.call(cxt)
      end
    end

    # lastly return with 404
    call_next cxt unless leaf
  end
end
