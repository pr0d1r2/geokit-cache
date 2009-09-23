class GeokitCachedGenerator < RspecModelGenerator

  def initialize(runtime_args, runtime_options = {})
    runtime_args = [
      'GeokitCache',

      'complete_address:string',

      'provider:string',
      'lng:float',
      'lat:float',
      'full_address:string',
      'state:string',
      'success:boolean',
      'accuracy:integer',
      'city:string',
      'country_code:string',
      'precision:string',
      'street_address:string',
      'zip:string',

      'complete:boolean'
    ]
    super
  end

end
