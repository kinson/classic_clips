module.exports = {
  mode: "jit",
  purge: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      colors: {
          'beef-red': 'rgb(215, 25, 33)'
        }
      }
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
