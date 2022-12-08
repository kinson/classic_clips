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
          'nd-pink': '#ea33d6',
          // 'nd-pink': '#EA33F1',
          // 'nd-purple': '#6000AA'
          'nd-purple': '#4C0A9B'
        },
        fontFamily: {
          'open-sans': ['Open Sans', 'sans-serif']
        },
        height: {
          '100': '30rem',
          '110': '34rem'
        },
        width: {
          '11/24': '45.83%',
          '27/24': '112.5%',
          '13/12': '108%',
          '110': '32rem'
        },
        minWidth: {
          '21': '21rem'
        },
        maxWidth: {
          '100': '30rem',
          '110': '32rem'
        },
        maxHeight: {
          '100': '30rem',
          '110': '34rem'
        },
        boxShadow: {
          'brutal': '4px 5px 0px #111',
          'notification': '6px 8px 3px #333'
        },
        letterSpacing: {
          'tightest': '-.1em'
        }
    }
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
