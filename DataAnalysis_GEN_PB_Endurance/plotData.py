from dotenv import dotenv_values
import mysql.connector 
from mysql.connector import Error
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import time
import pandas as pd
import numpy as np
import os

""" def conn_str() -> str:
    env = dotenv_values(".env")

    return "mysql+pymysql://%s:%s@%s/%s" % (
        env["DB_USER"],
        env["DB_PASSWORD"],
        env["DB_HOST"],
        env["DB_NAME"],
    ) """

# connect to Database
try:
    connection = mysql.connector.connect(host='localhost',
                                         database='aCe',
                                         user='root',
                                         password='')
    if connection.is_connected():
        db_Info = connection.get_server_info()
        print("Connected to MySQL Server version ", db_Info)
        cursor = connection.cursor()
        cursor.execute("select database();")
        record = cursor.fetchone()
        print("You're connected to database: ", record)

except Error as e:
    print("Error while connecting to MySQL", e)

## DO STUFF WITH DATABASE
# get data from database
c = connection.cursor()
c.execute("SELECT speed, timestamp FROM icu_heartbeat")
icu_heartbeat = pd.DataFrame(c.fetchall(), columns=['speed', 'timestamp'])

c.execute("SELECT soc_percent, timestamp FROM bms_pack_soc")
bms_pack_soc = pd.DataFrame(c.fetchall(), columns=['soc', 'timestamp'])

c.execute("SELECT battery_voltage, battery_current, timestamp FROM bms_pack_voltage_current")
bms_pack_voltage_current = pd.DataFrame(c.fetchall(), columns=['voltage', 'current', 'timestamp'])

## disconnect from Database
if connection.is_connected():
    cursor.close()
    connection.close()
    print("MySQL connection is closed")

## Define the CSV file path + datafiles
# Get the directory where the script is located
path = os.path.dirname(os.path.abspath(__file__))

file_names = ['data/icu_heartbeat.csv', 'data/bms_pack_voltage_current.csv']
data_lists = [icu_heartbeat, bms_pack_voltage_current]

# Write to CSV file
for i, data in enumerate(data_lists):
    csv_file_path = f"{path}/{file_names[i]}"
    data_lists[i].to_csv(csv_file_path, index=False)
    print(f'Data has been written to {csv_file_path}')

# plot data
ax = plt.axes()
ax.plot(bms_pack_soc.loc[:,"timestamp"], bms_pack_soc.loc[:,"soc"], label = "soc")
ax.plot(icu_heartbeat.loc[:,"timestamp"], 3.6 * icu_heartbeat.loc[:,"speed"] / 100, label = "speed")
ax.plot(bms_pack_voltage_current.loc[:,"timestamp"], np.multiply(bms_pack_voltage_current.loc[:,"voltage"], bms_pack_voltage_current.loc[:,"current"]) / -2 * 10**-9, label = "power")
ax.set_xlabel('Time of Day (UTC)')
ax.set_ylabel(r"speed / $m s^{-1}$")

fmt = ticker.FuncFormatter(lambda x, pos: time.strftime('%H:%M', time.gmtime(x)))
ax.xaxis.set_major_formatter(fmt)
ax.grid()

plt.show()



