defmodule BigBeefWeb.BeefLive.MenuComponent do
  use BigBeefWeb, :live_component

  import BigBeefWeb.BeefLive.Helpers

  def render(assigns) do
    ~H"""
    <div class="menu-floater">
      <div class={is_active(@page_type, "live")} phx-click="select-live">
        <svg
          viewBox="0 0 200 117"
          version="1.1"
          xmlns="http://www.w3.org/2000/svg"
          xmlns:xlink="http://www.w3.org/2000/svg"
        >
          <g
            id="Artboard"
            transform="translate(0.000000, -42.000000)"
            stroke="#D71921"
            stroke-width="3"
          >
            <path
              d="M5.10776435,90.1163868 C9.3885939,90.1163868 28.3941017,90.1163868 62.1242877,90.1163868 C62.495999,90.1164185 62.8370359,90.3226011 63.0097526,90.6517489 L78.5842568,120.332233 L78.5842568,120.332233 C97.3524998,83.146404 109.236064,60.1583598 114.23495,51.3681003 C121.733278,38.1827111 130.421228,45.578877 133.501235,51.3681003 C135.554574,55.2275825 142.067003,68.143678 153.038521,90.1163868 C171.753133,90.1163868 184.352667,90.1163868 190.837125,90.1163868 C200.563811,90.1163868 202.161998,111.655495 190.837125,111.655495 C183.287209,111.655495 166.114972,111.655495 139.320414,111.655495 L123.907015,81.3981765 C103.786719,122.271299 92.163113,145.430173 89.0361964,150.874797 C84.3458214,159.041734 72.7387367,159.041734 68.7604653,150.874797 C66.1082844,145.430173 59.8129792,132.357072 49.8745499,111.655495 C24.7982874,111.655495 9.87602557,111.655495 5.10776435,111.655495 C-2.04462748,111.655495 -1.35174268,90.1163868 5.10776435,90.1163868 Z"
              id="Path-11"
            >
            </path>
          </g>
        </svg>
        <p>Real Time</p>
      </div>
      <div class={is_active(@page_type, "stats")} phx-click="select-stats">
        <svg
          viewBox="0 0 200 155"
          version="1.1"
          xmlns="http://www.w3.org/2000/svg"
          xmlns:xlink="http://www.w3.org/2000/svg"
        >
          <g id="Artboard-46" fill-rule="nonzero" stroke="#D71921" stroke-width="3">
            <path
              d="M155,112.5 L163.75,112.5 C166.25,112.5 168.75,110 168.75,107.5 L168.75,17.5 C168.75,15 166.25,12.5 163.75,12.5 L155,12.5 C152.5,12.5 150,15 150,17.5 L150,107.5 C150,110 152.5,112.5 155,112.5 Z M80,112.5 L88.75,112.5 C91.25,112.5 93.75,110 93.75,107.5 L93.75,30 C93.75,27.5 91.25,25 88.75,25 L80,25 C77.5,25 75,27.5 75,30 L75,107.5 C75,110 77.5,112.5 80,112.5 L80,112.5 Z M117.5,112.5 L126.25,112.5 C128.75,112.5 131.25,110 131.25,107.5 L131.25,55 C131.25,52.5 128.75,50 126.25,50 L117.5,50 C115,50 112.5,52.5 112.5,55 L112.5,107.5 C112.5,110 115,112.5 117.5,112.5 L117.5,112.5 Z M193.75,131.25 L18.75,131.25 L18.75,6.25 C18.75,2.796875 15.953125,0 12.5,0 L6.25,0 C2.796875,0 0,2.796875 0,6.25 L0,137.5 C0,144.402344 5.59765625,150 12.5,150 L193.75,150 C197.203125,150 200,147.203125 200,143.75 L200,137.5 C200,134.046875 197.203125,131.25 193.75,131.25 Z M42.5,112.5 L51.25,112.5 C53.75,112.5 56.25,110 56.25,107.5 L56.25,80 C56.25,77.5 53.75,75 51.25,75 L42.5,75 C40,75 37.5,77.5 37.5,80 L37.5,107.5 C37.5,110 40,112.5 42.5,112.5 L42.5,112.5 Z"
              id="Shape"
            >
            </path>
          </g>
        </svg>
        <p>Stats</p>
      </div>
      <div class={is_active(@page_type, "archive")} phx-click="select-archive">
        <svg
          width="174px"
          height="161px"
          viewBox="0 0 175 180"
          version="1.1"
          xmlns="http://www.w3.org/2000/svg"
        >
          <g
            id="Artboard-Copy-4"
            transform="translate(0.000000, -26.000000)"
            fill-rule="nonzero"
            stroke="#D71921"
            stroke-width="3"
          >
            <path
              d="M163.45,166 C167.725,166 172,168.533333 172,171.066667 L172,171.066667 L172,179.933333 C172,182.466667 167.725,185 163.45,185 L163.45,185 L9.55,185 C5.275,185 1,182.466667 1,179.933333 L1,179.933333 L1,171.066667 C1,168.533333 5.275,166 9.55,166 L9.55,166 Z M9.55,120 L163.45,120 C167.725,120 172,122.533333 172,125.066667 L172,125.066667 L172,133.933333 C172,136.466667 167.725,139 163.45,139 L163.45,139 L9.55,139 C5.275,139 1,136.466667 1,133.933333 L1,133.933333 L1,125.066667 C1,122.533333 5.275,120 9.55,120 L9.55,120 Z M9.55,74 L163.45,74 C167.725,74 172,76.5333333 172,79.0666667 L172,79.0666667 L172,87.9333333 C172,90.4666667 167.725,93 163.45,93 L163.45,93 L9.55,93 C5.275,93 1,90.4666667 1,87.9333333 L1,87.9333333 L1,79.0666667 C1,76.5333333 5.275,74 9.55,74 L9.55,74 Z M163.45,28 C167.725,28 172,30.5333333 172,33.0666667 L172,33.0666667 L172,41.9333333 C172,44.4666667 167.725,47 163.45,47 L163.45,47 L9.55,47 C5.275,47 1,44.4666667 1,41.9333333 L1,41.9333333 L1,33.0666667 C1,30.5333333 5.275,28 9.55,28 L9.55,28 Z"
              id="Combined-Shape"
            >
            </path>
          </g>
        </svg>
        <p>Archive</p>
      </div>
      <div class={is_active(@page_type, "pledge")} phx-click="select-pledge">
        <svg
          width="154px"
          height="136px"
          viewBox="0 0 154 136"
          version="1.1"
          xmlns="http://www.w3.org/2000/svg"
        >
          <g id="Artboard-Copy-5" transform="translate(0.000000, 0.000000)" stroke="#D71921">
            <path
              d="M147.202546,84.4408606 C144.129696,81.6544625 139.338132,81.8367502 136.109036,84.4408606 L112.047056,103.685236 C109.093391,106.054839 105.417307,107.341468 101.630615,107.330991 L70.8318015,107.330991 C68.5306648,107.330991 66.6652249,105.465551 66.6652249,103.164414 C66.6652249,100.863277 68.5306648,98.9978374 70.8318015,98.9978374 L91.2193814,98.9978374 C95.3599169,98.9978374 99.2166043,96.1593571 99.8780483,92.0709039 C99.9595987,91.601386 99.9996829,91.1256036 99.9978374,90.6490596 C99.9892196,86.0528892 96.2608628,82.3315312 91.6646843,82.3315312 L49.9989187,82.3315312 C42.9720153,82.3333803 36.1592701,84.7504797 30.702461,89.1777373 L18.5933479,98.9978374 L4.16657656,98.9978374 C1.86543987,98.9978374 0,100.863277 0,103.164414 L0,128.163873 C0,130.46501 1.86543987,132.330455 4.16657656,132.330455 L97.0734215,132.330455 C100.858843,132.333408 104.532502,131.047627 107.489863,128.684695 L146.871824,97.1749602 C148.789361,95.6412675 149.93289,93.3399502 149.997141,90.8853557 C150.061393,88.4307613 149.039825,86.0727707 147.20515,84.4408606 L147.202546,84.4408606 Z"
              id="Shape"
              stroke-width="3"
              fill-rule="nonzero"
            >
            </path>
            <g id="Group" transform="translate(54.000000, 0.000000)">
              <path
                d="M0,47.3332167 C0.55476075,54.0243952 1.04244869,57.7323207 1.46306381,58.4569931 C2.44487267,60.1485391 7.69044617,62.9844927 8.4321463,62.9844927 C18.4671834,62.9844927 31.4333623,59.7706122 33.4380692,58.8685631 C35.442776,57.966514 38.5492026,54.5864354 39.7360787,53.8089443 C40.9229548,53.0314533 43.9235199,51.9809467 45.3841804,51.0429826 C46.8448408,50.1050185 47.5205298,48.5527055 50.0865224,47.1624002 C52.6525149,45.7720948 56.5533929,44.5544868 60.2289955,42.9997692 C62.6793973,41.9632909 64.2111476,38.3375337 64.8242465,32.1224976"
                id="Path-2"
                stroke-width="3"
                fill="#FFFFFF"
              >
              </path>
              <path
                d="M0,47.3332167 C0.55476075,54.0243952 1.04244869,57.7323207 1.46306381,58.4569931 C2.44487267,60.1485391 7.69044617,62.9844927 8.4321463,62.9844927 C18.4671834,62.9844927 31.4333623,59.7706122 33.4380692,58.8685631 C35.442776,57.966514 38.5492026,54.5864354 39.7360787,53.8089443 C40.9229548,53.0314533 43.9235199,51.9809467 45.3841804,51.0429826 C46.8448408,50.1050185 47.5205298,48.5527055 50.0865224,47.1624002 C52.6525149,45.7720948 56.5533929,44.5544868 60.2289955,42.9997692 C62.6793973,41.9632909 64.2111476,38.3375337 64.8242465,32.1224976"
                id="Path-2"
                stroke-width="3"
              >
              </path>
              <path
                d="M25.099004,0.250097195 C27.8012402,0.250097195 35.0572301,3.50680062 35.7943014,4.9216117 C36.517367,6.30953877 35.4907427,9.18771026 36.517367,10.1036202 C36.8524837,10.4025969 40.7877312,10.4668723 43.4501006,9.41391269 C44.6641961,8.93374136 61.0838697,18.5656902 62.8794692,22.1836239 C65.4807109,27.4248374 65.1018089,30.6690046 64.7484431,32.3803903 C63.4864033,38.4925738 51.550828,35.8599853 40.8180314,45.6293079 C38.6324823,47.6186621 34.5724747,51.7561558 32.5,51.7561558 C25.099004,51.7561558 16.4153789,54.825671 15.8450066,54.8586893 C10.6031835,55.162133 10.6031835,55.162133 8.1500978,54.3792528 C5.69701205,53.5963727 0.321277092,50.4455275 0.00725082902,47.3533465 C-0.306775434,44.2611656 9.68065951,34.5939878 10.2696025,32.3803903 C10.7274299,30.6596031 9.68065951,29.3059236 14.6452652,22.1836239 C15.8450066,20.4624565 13.7533386,14.768233 13.7533386,11.8564159 C13.7533386,8.94459872 18.3077547,-1.76243156 25.099004,0.250097195 Z"
                id="Path"
                stroke-width="3"
                fill="#FFFFFF"
              >
              </path>
              <path
                d="M25.099004,0.250097195 C27.8012402,0.250097195 35.0572301,3.50680062 35.7943014,4.9216117 C36.517367,6.30953877 35.4907427,9.18771026 36.517367,10.1036202 C36.8524837,10.4025969 40.7877312,10.4668723 43.4501006,9.41391269 C44.6641961,8.93374136 61.0838697,18.5656902 62.8794692,22.1836239 C65.4807109,27.4248374 65.1018089,30.6690046 64.7484431,32.3803903 C63.4864033,38.4925738 51.550828,35.8599853 40.8180314,45.6293079 C38.6324823,47.6186621 34.5724747,51.7561558 32.5,51.7561558 C25.099004,51.7561558 16.4153789,54.825671 15.8450066,54.8586893 C10.6031835,55.162133 10.6031835,55.162133 8.1500978,54.3792528 C5.69701205,53.5963727 0.321277092,50.4455275 0.00725082902,47.3533465 C-0.306775434,44.2611656 9.68065951,34.5939878 10.2696025,32.3803903 C10.7274299,30.6596031 9.68065951,29.3059236 14.6452652,22.1836239 C15.8450066,20.4624565 13.7533386,14.768233 13.7533386,11.8564159 C13.7533386,8.94459872 18.3077547,-1.76243156 25.099004,0.250097195 Z"
                id="Path"
                stroke-width="3"
              >
              </path>
              <line
                x1="34.6902633"
                y1="14.5133311"
                x2="21.2623622"
                y2="33.5950853"
                id="Path-3"
                stroke-opacity="0.8"
                stroke-width="4"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
              </line>
            </g>
          </g>
        </svg>
        <p>Pledge</p>
      </div>
    </div>
    """
  end
end
