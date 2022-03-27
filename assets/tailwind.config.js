module.exports = {
  mode: "jit",
  purge: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      colors: {
          'beef-red': 'rgb(215, 25, 33)',
          // 'nd-yellow': '#DAFF4F',
          'nd-yellow': '#DDFE52',
          // 'nd-pink': '#E934D7',
          'nd-pink': '#EA33F1',
          // 'nd-purple': '#6000AA'
          'nd-purple': '#4C0A9B'
        },
        fontFamily: {
          'open-sans': ['Open Sans', 'sans-serif']
        },
        width: {
          '11/24': '45.83%',
          '27/24': '112.5%',
          '13/12': '108%'
        },
        boxShadow: {
          'brutal': '4px 5px 0px #111',
          'notification': '6px 8px 3px #333'
        }
    }
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
