3.2.2	Métricas de funcionalidad
	Punto de función (PF)
a.	Calcule el PFS, indique cuales son: Las entradas, salidas, consultas, archivos lógicos e interfases externas de su aplicación.
(Tenga en cuenta el documento de requisitos y todas las funcionalidades para determinar las medidas)

Caso	Entrada	Salida	Consulta	Archivos lógicos	Interfaz externa
1	1S			1S	
2	1S				
3	1S			1S	
4			1S		
5	1S			1S	
6	1S			1S	
7	1S			1S	
8			1S		
9	1S			1S	
10	1S			1S	
11	1S			1S	
12			1S		
13			1S		
14				1S	
15			1S		
16	1M			1M	
17			1M		
18			1M		
19	1M			1M	
20		1M			
21	1M			1M	
22			1S		
23		1C			1S


PFS:
	simple	media	compleja	resultado
Entradas :	9 x 3	3x4		39
Salidas:		1 x5	1 x7	12
Consulta:	6x3	2x4		26
Archivos lógicos:	9 x7	3 x10		93
Interfaz externa	1x5			5
PFS	175



b.	Calcule el FCP, teniendo en cuenta el documento de RNF

#	Factor de Ajuste	Descripción	Peso
1	Comunicación de Datos	¿Cuántas facilidades de comunicación y opciones para ayudar con el intercambio de información con la aplicación o el sistema?	4
2	Procesamiento distribuido de los datos	¿Dificultan o hacen que las funcionalidades de los datos o las aplicaciones estén distribuidas en dos o más procesadores diferentes (esto también concierne a las funciones internas? ¿Cómo se manejaron los datos y las funciones del sistema distribuido)?	3
3	Rendimiento	¿Existen requerimientos de velocidad o tiempo de respuesta?	4
4	Configuraciones fuertemente utilizadas	¿Qué tan intensivamente se utiliza la plataforma de hardware donde se ejecutará la aplicación, y la plataforma del sistema?	2
5	Tasas de Transacción	¿Con qué frecuencia se ejecutan las transacciones? diarias, semanales, mensuales...	1
6	Entrada de datos On-line	¿Qué porcentaje de la información se ingresa on-line?	4
7	Diseño para la eficiencia de usuario final	¿Se diseñó la aplicación para maximizar la eficiencia del usuario final?	4
8	Actualizaciones on-line	¿Cuántos archivos lógicos internos se actualizan por una transacción on-line?	3
9	Procesamiento complejo	¿Hay procesamientos lógicos o matemáticos intensos en la aplicación?	2
10	Reusabilidad	¿La aplicación o sus componentes fueron diseñados para suplir una o muchas de las necesidades de los usuarios	4
11	Facilidad de instalación	¿Es muy difícil la instalación y la conversión al nuevo sistema?	1
12	Facilidad de operación	¿Cómo de efectivos y automatizados son los procedimientos de arranque, parada, backup y retorno del sistema?	4
13	Puestos Múltiples	¿La aplicación fue concebida para su instalación en múltiples sitios y organizaciones?	3
14	Facilidad de cambio	¿La aplicación fue concebida para facilitar los cambios sobre la misma?	4
	GRADO TOTAL DE INFLUENCIA (TDI)		43

FCP= 0.65 + (0.01 x Puntos de Complejidad de Procesamiento)
FCP = 0.65+(0.01 x 43)
FCP= 1.08

c.	Calcule el tamaño en PF y el tamaño en LOC, KLOC

            PF= PFS * FCP
PF = 175 * 1.08
PF = 189
KLOC= (PF * Líneas de código por cada PF)/1000
KLOC =(189 * 58)/1000
KLOC = 10,962 LOC
