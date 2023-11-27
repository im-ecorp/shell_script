#!/bin/bash

clear; 
echo -e "Checking for tools dependent on this script \n"
echo "Thank you for waiting"



# Define the software to check
SOFTWARE="openssl libssl-dev"

# Check which package manager is available
if command -v apt-get &> /dev/null; then
	# Add dots to represent the checking progress
	for (( i=1; i<=20; i++ )); do
		echo -n "."
		sleep 0.1  # Adjust sleep duration as needed
	done
	# Use apt-get to check if the software is installed
	if ! dpkg -s $SOFTWARE &> /dev/null; then
		
		# Install the software using apt-get
		sudo apt-get -qq update
		sudo apt-get -qq install -y $SOFTWARE
		echo "$SOFTWARE was successfully installed"
	#else
		# The software is already installed
		#echo "$SOFTWARE is already installed"
	fi
	
elif command -v yum &> /dev/null; then
	# Add dots to represent the checking progress
	for (( i=1; i<=20; i++ )); do
		echo -n "."
		sleep 0.1  # Adjust sleep duration as needed
	done
	# Use yum to check if the software is installed
	if ! yum list installed $SOFTWARE &> /dev/null; then
		echo -n "."
		sleep 1
		# Install the software using yum
		sudo yum update -q
		sudo yum install -q -y $SOFTWARE
		echo "$SOFTWARE was successfully installed"
	#else
		# The software is already installed
		#echo "$SOFTWARE is already installed"
	fi

#else
	# Neither apt-get nor yum is available
	#echo "Neither apt-get nor yum is available"
fi


# Define functions for each menu option

function add_user {
    echo -e "Add user \n"
	echo "1 - Create single user"
	echo "2 - Create multi user"
	echo "3 - Back to the main menu"
    read -p "~: " choice
    case $choice in
        1 | -s | --single)
			clear;
			echo -e "Please fill in the following values.\n"
			echo -n "username : " ; read -r username
			if [ $(grep -w "$username" /etc/passwd) ] ; then
				echo "This username is alrady exist ! "
				sleep 2;
				clear;
			else
				echo -n "password : " ; read -r password
				passmaker=$(openssl passwd -1 $password)
				useradd -m -p "$passmaker" "$username"
				usermod --shell /bin/bash $username
				echo "$(date +"%a %b %d %H:%M:%S %z %Y") $username created :>"
			fi
			sleep 2;
			clear
            ;;
        2 | -m | --multi)
			clear;
            echo "How many user do you want to created ? "
			echo -n "Enter range -Ex. 1001 1004 : " ; read input
			
			st=$(echo $input | awk -F " " '{print $1}')
			en=$(echo $input | awk -F " " '{print $2}')
			
			#if st is empty, set it to 1

			if [ -z "$en"  ]; then
				en=$st
				st=1
				
			fi
			
			
			echo -n "Enter your name prefix : " ; read -r prefix
			
			if [ -z "$prefix" ] ; then
			
				prefix=${prefix:-user}
			
			fi
			
			if ! [[ "$st" =~ "^[0-9]+$" ]] ; then
				echo ""
			fi

			if ! [[ "$en" =~ "^[0-9]+$" ]] ; then
				echo ""
			fi
			
			for (( i=$st ; i<=$en ; i++ )) ;
			do
				if [ $(grep -w "$prefix$i" /etc/passwd) ] ; then
					echo "$prefix$i is allready exist !"
				else
					numpassgen="$prefix$i""Pass""$[$RANDOM % 99999 + 10000]"
					password=$(openssl passwd -1 $numpassgen)
					useradd -m -p "$password" "$prefix$i"
					usermod --shell /bin/bash "$prefix$i"
					echo $prefix$i:$numpassgen >> '/root/password.txt'
					echo $(date +"%a %b %d %H:%M:%S %z %Y") $prefix$i created
				fi
			done
			sleep 2;
			echo "You can see your password on /root/password.txt "
			sleep 2;
			clear
            ;;
        3 | q | quit | exit )
			clear;
            echo "Going back to the main menu..."
			sleep 2;
			clear
            ;;
        *)
			clear;
            echo "Invalid choice."
			sleep 2;
			clear
            add_user
            ;;
    esac
}

function delete_user {
    echo -e "Delete user \n"
	echo "1 - Delete single user"
	echo "2 - Delete multi user"
	echo "3 - Back to the main menu"
    read -p "~: " choice
    case $choice in
        1 | -s | --single)
			clear;
            echo -n "What username do you want to remove ?" ; read -r username
			deluser --quiet --remove-home "$username"
			echo $(date +"%a %b %d %H:%M:%S %z %Y") $username successfully deleted
			sleep 2;
			clear
            ;;
        2 | -m | --multi)
			clear
            echo "How many user want to remove ? "
			echo -n "Enter ranage /Ex. 1001 1004 : " ; read input
			st=$(echo $input | awk -F " " '{print $1}')
			en=$(echo $input | awk -F " " '{print $2}')
			
			#if st is empty, set it to 1

			if [ -z "$en"  ]; then
				en=$st
				st=1
				
			fi

			echo -n "Enter your name prefix : " ; read -r prefix
			
			prefix=${prefix:-user}
			
			if ! [[ "$st" =~ "^[0-9]+$" ]] ; then
				echo ""
			fi
		
			if ! [[ "$st" =~ "^[0-9]+$" ]] ; then
				echo ""
			fi

			for (( i=$st ; i<=$en ; i++)) ;
			do
				if [ $(grep -w "$prefix$i" /etc/passwd)  ] ; then
					deluser --quiet --remove-home "$prefix$i"
					echo $(date +"%a %b %d %H:%M:%S %z %Y") "$prefix$i" deleted !
				else
					echo "$prefix$i is allrady deleted !"
				fi
			done
			sleep 2;
			clear
            ;;
        3 | q | quit | exit )
			clear;
            echo "Going back to the main menu..."
			sleep 2;
			clear
            ;;
        *)
			clear;
            echo "Invalid choice."
			sleep 2;
			clear
            delete_user
            ;;
    esac
}


function help {
	# Display Help
	echo -e "Manual help page . \n"
	echo -e "Syntax: script [-c --create |-d --delete] [-s --single |-m --multi] \n"
	echo "options:"
	echo "-c, --create		Create User."
	echo "-d, --delete		Delete User."
	echo "-s, --single		Create or Delete Single username."
	echo "-m, --multi		Create or Delete Multi username."
	echo
}


# Define the main menu loop

while true; do
	clear;
    # Print the main menu
    echo ""
    echo "Welcome to bash script"
    echo "Please enter one of the following numbers:"
    echo "1 - Add user"
    echo "2 - Delete user"
    echo "3 - Exit the script"
    echo ""
    read -p "~: " choice

    # Handle the user's choice
    case $choice in
        1 | -c | --create)
			clear;
            add_user
            ;;
        2 | -d | --delete)
			clear;
            delete_user
            ;;
        3 | q | quit | exit )
            echo "Exiting..."
            exit 0
            ;;
		-h | --help)
			help
			;;
        *)
            echo "Invalid choice."
            ;;
    esac
done
