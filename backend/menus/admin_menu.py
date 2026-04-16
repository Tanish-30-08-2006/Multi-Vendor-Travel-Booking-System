import questionary
from questionary import Style

# Import all analytical queries
from query_engine.admin_queries import (
    get_platform_revenue,
    get_vendor_ledger,
    get_pending_refunds,
    get_top_vendors,
    get_top_destinations,
    get_feedback_summary,
    get_poor_services,
    get_monthly_trends,
    get_insurance_summary
)
from query_engine.vendor_queries import get_all_vendors

# High-Visibility Admin Style
admin_style = Style([
    ('qmark', 'fg:#FF3D00 bold'),
    ('question', 'bold'),
    ('answer', 'fg:#FF3D00 bold'),
    ('pointer', 'fg:#FF3D00 bold'),
    ('highlighted', 'fg:#FF3D00 bold'),
    ('separator', 'fg:#666666'),
])


def admin_menu():
    """
    Exhaustive Admin Portal command center with hierarchical 
    access to financials, operations, and quality metrics.
    """

    while True:
        print("\n" + "═"*65)
        print("           🛡️  PLATFORM ADMINISTRATION COMMAND CENTER")
        print("═"*65)

        section = questionary.select(
            "Main Control Panels:",
            choices=[
                "💰 REVENUE & FINANCIALS",
                "⚙️  OPERATIONAL MANAGEMENT",
                "⭐ REVIEWS & QUALITY",
                "📊 TRENDS & INSURANCE",
                "⬅️  Back to Main Menu"
            ],
            style=admin_style
        ).ask()


        if section == "⬅️  Back to Main Menu":
            break


        # --------------------------------------------------------------------
        # 1. REVENUE & FINANCIALS
        # --------------------------------------------------------------------

        if section == "💰 REVENUE & FINANCIALS":
            sub_choice = questionary.select(
                "Financial Tools:",
                choices=["🏦 Platform Revenue Summary", "📜 Vendor Financial Ledger", "🔙 Back"],
                style=admin_style
            ).ask()

            if sub_choice == "🏦 Platform Revenue Summary":
                period = questionary.select(
                    "Select Period:", 
                    choices=["Daily", "Weekly", "Monthly", "Annual"], 
                    style=admin_style
                ).ask()
                
                breakdown = questionary.select(
                    "Select Breakdown:", 
                    choices=["Overall", "By Vendor", "By Service Type", "By Destination", "By Transport Mode"], 
                    style=admin_style
                ).ask()
                
                get_platform_revenue(period, breakdown)

            elif sub_choice == "📜 Vendor Financial Ledger":
                vendors = get_all_vendors()
                if not vendors: continue
                v_choices = [f"{v[1]} (ID: {v[0]})" for v in vendors]
                v_pick = questionary.select("Select Vendor:", choices=v_choices).ask()
                if not v_pick: continue
                v_id = int(v_pick.split("(ID: ")[1].replace(")", ""))
                get_vendor_ledger(v_id)


        # --------------------------------------------------------------------
        # 2. OPERATIONAL MANAGEMENT
        # --------------------------------------------------------------------

        elif section == "⚙️  OPERATIONAL MANAGEMENT":
            sub_choice = questionary.select(
                "Operation Tools:",
                choices=["💸 Pending Refunds", "🏆 Top Vendors (Rankings)", "📍 Top Destinations & Routes", "🔙 Back"],
                style=admin_style
            ).ask()

            if sub_choice == "💸 Pending Refunds":
                get_pending_refunds()

            elif sub_choice == "🏆 Top Vendors (Rankings)":
                rank = questionary.select("Rank By:", choices=["Booking Volume", "Revenue", "Average Customer Rating"]).ask()
                get_top_vendors(rank)

            elif sub_choice == "📍 Top Destinations & Routes":
                period = questionary.select("Select Period:", choices=["This Year", "All Time"]).ask()
                get_top_destinations(period)


        # --------------------------------------------------------------------
        # 3. REVIEWS & QUALITY
        # --------------------------------------------------------------------

        elif section == "⭐ REVIEWS & QUALITY":
            sub_choice = questionary.select(
                "Quality Checks:",
                choices=["👨‍👩‍👧‍👦 Customer Feedback Summary", "🚨 Services with Poor Ratings", "🔙 Back"],
                style=admin_style
            ).ask()

            if sub_choice == "👨‍👩‍👧‍👦 Customer Feedback Summary":
                vendors = get_all_vendors()
                if not vendors: continue
                v_choices = [f"{v[1]} (ID: {v[0]})" for v in vendors]
                v_pick = questionary.select("Select Vendor:", choices=v_choices).ask()
                if not v_pick: continue
                v_id = int(v_pick.split("(ID: ")[1].replace(")", ""))
                s_type = questionary.select("Select Service Type:", choices=["Hotel", "Transport", "Package", "All"]).ask()
                get_feedback_summary(v_id, s_type)

            elif sub_choice == "🚨 Services with Poor Ratings":
                get_poor_services()


        # --------------------------------------------------------------------
        # 4. TRENDS & INSURANCE
        # --------------------------------------------------------------------

        elif section == "📊 TRENDS & INSURANCE":
            sub_choice = questionary.select(
                "Trend Analysis:",
                choices=["📈 Monthly Booking Volume", "🛡️  Insurance Claim Summary", "🔙 Back"],
                style=admin_style
            ).ask()

            if sub_choice == "📈 Monthly Booking Volume":
                get_monthly_trends()
            
            elif sub_choice == "🛡️  Insurance Claim Summary":
                get_insurance_summary()
