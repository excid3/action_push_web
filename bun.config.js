await Bun.build({
  entrypoints: ['./app/assets/javascripts/components/action_push_web.js'],
  outdir: './app/assets/javascripts/',
  external: ["HTMLElement"]
})
