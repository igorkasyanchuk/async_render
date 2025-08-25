module AsyncRender
  module Utils
    def generate_token(partial)
      # Fast random token generation using Random.bytes
      partial_id = partial.downcase.gsub(/[^a-z0-9\/]/, "").slice(0, 100)
      random_hex = Random.bytes(5).unpack1("H*")
      "#{partial_id}/#{random_hex}"
    end

    def build_memoized_render_key(partial, locals)
      return partial if locals.nil? || locals.empty?
      [ partial, locals.to_a.sort_by { |(k, _)| k.to_s } ]
    end

    def normalize_locals(locals, locals_kw)
      if locals.nil?
        locals_kw
      elsif locals_kw.empty?
        locals
      else
        locals.merge(locals_kw)
      end
    end
  end
end
