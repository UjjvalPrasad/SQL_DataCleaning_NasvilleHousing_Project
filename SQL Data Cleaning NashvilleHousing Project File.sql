-- DATA CLEANING PROJECT

select * from [dbo].[Data_Cleaning ];

-- Standardize Date Format

select saledate, convert(date, saledate)
from [dbo].[Data_Cleaning ];

update [Data_Cleaning ]
set saledate = convert(date, saledate);

-- Populte Property Address Date
select * from [Data_Cleaning ]
-- where PropertyAddress is null;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [Data_Cleaning ] a
join [Data_Cleaning ] b on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [Data_Cleaning ] a
join [Data_Cleaning ] b on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-- Breaking out Address into Individual Coloumns (Address, City, State)
select PropertyAddress from [Data_Cleaning ];

select 
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(propertyaddress)) as Address
from [Data_Cleaning ]

ALTER TABLE data_cleaning
Add PropertySplitAddress Nvarchar(255);

Update [Data_Cleaning ]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE data_cleaning
Add PropertySplitCity Nvarchar(255);

Update [Data_Cleaning ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select OwnerAddress 
from [Data_Cleaning ];

select 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from [Data_Cleaning ];

ALTER TABLE data_cleaning
Add OwnerSplitAddress Nvarchar(255);

Update [Data_Cleaning ]
SET OwnerSplitAddress  = parsename(replace(OwnerAddress,',','.'),3)

ALTER TABLE data_cleaning
Add OwnerSplitCity Nvarchar(255);

Update [Data_Cleaning ]
SET OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

ALTER TABLE data_cleaning
Add PropertySplitState Nvarchar(255);

Update [Data_Cleaning ]
SET OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1);

select * from [Data_Cleaning ];

-- Remove Duplicates
with rownumcte as
(
select *,
row_number() over(
partition by parcelid,
			 propertyaddress,
			 saleprice,
			 saledate,
			 legalreference 
			 order by 
				uniqueid) rownum
from [Data_Cleaning ]
-- order by ParcelID
)
select * from rownumcte
where rownum > 1
order by PropertyAddress;

with rownumcte as
(
select *,
row_number() over(
partition by parcelid,
			 propertyaddress,
			 saleprice,
			 saledate,
			 legalreference 
			 order by 
				uniqueid) rownum
from [Data_Cleaning ]
-- order by ParcelID
)
delete from rownumcte
where rownum > 1;

-- Delete Unused Coloumns
select * from [Data_Cleaning ];

alter table data_cleaning
drop column owneraddress, taxdistrict, propertyaddress;