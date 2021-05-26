from os import system, name, getcwd
from stopwatch import Stopwatch
import re
import requests
import time

timer = Stopwatch()


def clear():
    if name == 'nt':
        _ = system('cls')
    else:
        _ = system('clear')


def print_progress_bar (iteration, total, prefix='', suffix='', decimals=1,
                        length=100, fill='█', print_end="\r",
                        title='MSAW', lat='', lon='', current=0):
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    clear()
    print(f'\r\n\n Title: {title}\n LAT: {lat}\n LON: {lon}\n\n Downloading {current} of {total}\n {prefix} |{bar}| {percent}% {suffix}', end = print_end)
    if iteration == total:
        print()


def get_and_save_data(title="KSLC", lat="40.7883933", lon="-111.9777733", radius=50, width=2, ceiling=300, offsetX=50,
                      out_file_name="Output.xml"):
    """
    Grab MSAW data for vSTARS from www.myfsim.com and save to a XML file.
    """
    timer.start()

    text_area_re = re.compile(r'(<\/*textarea([\s\S]*?)>)')

    options = {'Title': f'{title}', 'Lat': f'{lat}', 'Lon': f'{lon}',
               'Radius': f'{radius}', 'Width': f'{width}', 'Ceiling': f'{ceiling}'}

    print_progress_bar(0, offsetX, prefix='Progress: ', suffix="Complete", length=50,
                       title=title, lat=lat, lon=lon, current=1)
    for i in range(1, offsetX + 1):
        in_data_range = False
        count = 0
        if i > 1:
            options['offsetX'] = str(i)
            options['dooffset'] = '1'

        r = requests.get('http://www.myfsim.com/sectorfilecreation/MSAW_creator.php', params=options)
        with open(out_file_name, "a") as file:
            for line in r.text.split('\n'):
                if text_area_re.search(line) and count == 0:
                    in_data_range = True
                    count += 1
                    continue
                elif text_area_re.search(line) and count != 0:
                    file.write("      </SystemVolume>\n")
                    break
                elif in_data_range:
                    if len(line) > 2:
                        if line.find("\r") == -1:
                            file.write(line + "\n")
                        else:
                            file.write(line)
                else:
                    continue

        time.sleep(0.01)
        print_progress_bar(i, offsetX, prefix='Progress: ', suffix="Complete", length=50,
                           title=title, lat=lat, lon=lon, current=i)
    timer.stop()


def get_user_input():
    while True:
        print("  Type the FAA ID or ICAO Code of the Airport \n  that will be the center of the MSAW Grid")
        apt = input("\n  Airport FAA ID or ICAO: ").strip().upper()
        good_input = True
        if len(apt) <= 1:
            good_input = False
            clear()
            print("\n  Airport FAA ID or ICAO must contain more than 1 character.\n")
            continue
        if not apt.isalpha():
            good_input = False
            clear()
            print("\n  Airport FAA ID or ICAO must contain only alphabet characters [A-Z, a-z].\n")
            continue
        if good_input:
            return apt


def calculate_duration(duration):
    duration = round(duration, 2)
    if 60 < duration:
        return str(round(duration/60, 2)) + " minutes"
    else:
        return str(round(duration, 2)) + " seconds"


def start_messages():
    clear()
    print("\n\n  CREATE A .xml FILE BY USING THE MYFSIM.COM MSAW_CREATOR.php\n")
    print("  Parameters that will be used:"
          "\n              RADIUS:      50nm"
          "\n              WIDTH:       2nm"
          "\n              ELEVELATION: 300ft\n\n")
    print("  The .xml will be saved in the same directory as this program."
          f"\n\t{getcwd()}\n\n")


def complete_messages(apt=''):
    clear()
    duration = calculate_duration(timer.duration)
    print("          **************************************")
    print("          **             Complete             **")
    print(f"          **    Elapsed time: {duration}{(' ')*(16-len(duration))}**")
    print("          **************************************\n\n")
    print(f"          Your {apt}_MSAW.xml can be found here:")
    print(f"        {getcwd()}\\{apt}_MSAW.xml\n\n")


def get_lat_lon(apt_code):
    url = f"https://www.airnav.com/airport/{apt_code}"
    lat_lon_re = re.compile(r'(\d{2}\.\d*),(-*\d{3}\.\d*)')
    airnav_response = requests.get(url)
    lat = lat_lon_re.search(airnav_response.text).group(1)
    lon = lat_lon_re.search(airnav_response.text).group(2)
    return lat, lon


def main():
    start_messages()
    apt = get_user_input()
    lat, lon = get_lat_lon(apt)
    get_and_save_data(title=f'{apt}_MSAW', lat=lat, lon=lon, out_file_name=f'{apt}_MSAW.xml')
    complete_messages(apt)


if __name__ == '__main__':
    main()