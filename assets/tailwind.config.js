module.exports = {
  mode: "jit",
  purge: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      colors: {
          'beef-red': 'rgb(215, 25, 33)',
          'nd-yellow': '#DAFF4F',
          'nd-pink': '#E934D7',
          'nd-purple': '#6000AA'
        },
        fontFamily: {
          'open-sans': ['Open Sans', 'sans-serif']
        },
        width: {
          '14/12': '116%',
          '13/12': '108%'
        },
        boxShadow: {
          'brutal': '4px 5px 0px #111'
        }
    }
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
