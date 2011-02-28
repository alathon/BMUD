/* Clients own the password, not the mob. */ 
client
	var
		__password

	proc
		// TODO: Hash password?
		__passwordify(n)
			return n

		setPassword(n)
			__password = __passwordify(n)

		isPassword(p)
			return __password == __passwordify(p)
