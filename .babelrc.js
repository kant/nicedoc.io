module.exports = {
  presets: ['next/babel'],
  plugins: [
    [
      'styled-components',
      {
        ssr: true,
        displayName: true,
        preprocess: false
      }
    ],
    [
      'module-resolver',
      {
        root: ['.'],
        alias: {
          core: './core',
          styles: './styles',
          components: './components',
          routes: './routes'
        },
        cwd: 'babelrc'
      }
    ],
    'inline-dotenv',
    [
      'wrap-in-js',
      {
        extensions: ['css$', 'scss$']
      }
    ]
  ]
}
