module AsyncRender
  module MemoizedHelper
    include AsyncRender::Utils

    def memoized_render(partial, locals = nil, formats: [ :html ], **locals_kw)
      return render(partial, locals) unless AsyncRender.enabled

      effective_locals = normalize_locals(locals, locals_kw)
      key = build_memoized_render_key(partial, effective_locals)
      AsyncRender.memoized_cache.compute_if_absent(key) do
        Rails.logger.info "[AsyncRender] Memoizing: #{partial}" if Rails.env.local?
        ApplicationController.renderer.render(partial: partial, locals: effective_locals, formats: formats)
      end
    end
  end
end
