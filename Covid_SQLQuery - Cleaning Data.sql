/*

Cleaning Data in SQL Queries

*/


select *
from PortfolioProject.dbo.[Nashville Housing]


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format(solve cell format)

--1) If it doesn't Update properly
select SaleDate , CONVERT(date,saledate)
from PortfolioProject.dbo.[Nashville Housing]

update [Nashville Housing]
set SaleDate = CONVERT(date,saledate)

--2) If it doesn't Update properly

select SaleDateConverted , CONVERT(date,saledate)
from PortfolioProject.dbo.[Nashville Housing]

ALter Table [Nashville Housing]
add SaleDateConverted date ;  -- add new column at table to add new data for converted date and solve issue of add converted date to original column 

update [Nashville Housing]
set SaleDateConverted = CONVERT(date,saledate) -- set the converted date to the new column created


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data (solve null cells)
select *
from PortfolioProject.dbo.[Nashville Housing]
where PropertyAddress is null



	-- to check cells that have null result
select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , isnull(a.PropertyAddress , b.PropertyAddress) --The ISNULL() function returns a specified value if the expression is NULL. 
																													   --If the expression is NOT NULL, this function returns the expression.
from PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ] -- used to show rows without duplication
where a.PropertyAddress is null

		--use update to update the null cells at PropertyAddress by correct data
Update a -- a is refer for table that will be updated , use update to update the null cells at PropertyAddress by correct data
set PropertyAddress = isnull(a.PropertyAddress , b.PropertyAddress)
from PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select *
--select PropertyAddress
from PortfolioProject.dbo.[Nashville Housing]


select -- using PARSENAME (replace(Column 1 , ',' , '.') , 2 )   to devide cell data and it work backward , pull back backword data to the forword
PARSENAME (replace(PropertyAddress , ',' , '.') , 2 )
,PARSENAME (replace(PropertyAddress , ',' , '.') , 1 )
,PARSENAME (replace(OwnerAddress , ',' , '.') , 3 )
,PARSENAME (replace(OwnerAddress , ',' , '.') , 2 )
,PARSENAME (replace(OwnerAddress , ',' , '.') , 1 )
from PortfolioProject.dbo.[Nashville Housing]

ALter Table PortfolioProject.dbo.[Nashville Housing]
add PropertySplitAddress VARCHAR (255) ;

ALter Table PortfolioProject.dbo.[Nashville Housing]
add PropertySplitCity VARCHAR(255);

ALter Table PortfolioProject.dbo.[Nashville Housing]
add OwnerSplitAddress VARCHAR (255) ;

ALter Table PortfolioProject.dbo.[Nashville Housing]
add OwnerSplitCity VARCHAR (255);

ALter Table PortfolioProject.dbo.[Nashville Housing]
add OwneSplitState VARCHAR (255);


update PortfolioProject.dbo.[Nashville Housing]
set PropertySplitAddress = PARSENAME (replace(PropertyAddress , ',' , '.') , 2 )

update PortfolioProject.dbo.[Nashville Housing]
set PropertySplitCity = PARSENAME (replace(PropertyAddress , ',' , '.') , 1 )

update PortfolioProject.dbo.[Nashville Housing]
set OwnerSplitAddress = PARSENAME (replace(OwnerAddress , ',' , '.') , 3 )

update PortfolioProject.dbo.[Nashville Housing]
set OwnerSplitCity = PARSENAME (replace(OwnerAddress , ',' , '.') , 2 )

update PortfolioProject.dbo.[Nashville Housing]
set OwneSplitState = PARSENAME (replace(OwnerAddress , ',' , '.') , 1 )

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

-- to check the Duplication at the column
select distinct(SoldAsVacant) , count(SoldAsVacant) -- Distinct to remove Duplication at one column
from PortfolioProject.dbo.[Nashville Housing]
group by SoldAsVacant
order by 2

-- to Replace the Date at the column
select SoldAsVacant
,case when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'No'
	  Else soldasvacant
	  End 
from PortfolioProject.dbo.[Nashville Housing]

-- to update the new Date at the Original column
update PortfolioProject.dbo.[Nashville Housing]
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'No'
	  Else soldasvacant
	  End

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

--to Find Duplicaste rows 
-- Using Cte )one-time result set that only exists for the duration of the query ) to help use as temp table 
with Rownumcte as (
select *,
	row_number() over (
		partition by
			ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference
		order by ParcelID
			) row_num
from PortfolioProject.dbo.[Nashville Housing] 
)
select*
from Rownumcte
where Row_num >1
order by ParcelID


--to Delete Duplicaste rows 
with Rownumcte as (
select *,
	row_number() over (
		partition by
			ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference
		order by ParcelID
			) row_num
from PortfolioProject.dbo.[Nashville Housing] 
)
Delete
from Rownumcte
where Row_num >1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProject.dbo.[Nashville Housing] 

Alter Table PortfolioProject.dbo.[Nashville Housing] 
Drop Column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















